// IMMER — local performer-driven server.
//
// Loaded by [node.script server.js] in immer.maxpat.
// Performers visit http://<your-lan-ip>:<PORT>/ from any phone/laptop on
// the same wifi, enter a name, then drive their own role (Dance / Music)
// from the page. The patch shows the live state and coverage info.
//
// Two transports:
//   • HTTP   — serves the single-page client from ./public/index.html
//   • WS     — drives real-time state updates both ways
//
// One outlet (node.script default). Routed in Max by leading symbol:
//   performer add <name>         — new joiner   (use to set a cellblock row)
//   performer remove <name>      — left
//   performer role <name> <role> — current role (music | dance | idle)
//   roster <name1> <name2> ...   — full ordered roster (use to repaint)
//   countdown <secs>             — seconds remaining
//   status <text>                — human-readable status line
//   url <http://...>             — server URL to print/QR
//   coverage <json>              — full coverage blob (see buildCoverage)
//   complete bang                — piece finished

const http = require("http");
const fs   = require("fs");
const path = require("path");
const os   = require("os");

let Max     = null;
let WSServer = null;
try {
  // max-api is injected by node.script when running inside Max.
  // Outside Max (plain `node server.js`) we fall back to a console shim
  // so the server can still be smoke-tested from a terminal.
  Max = require("max-api");
} catch (e) {
  Max = {
    post:    (...a) => console.log("[max.post]", ...a),
    outlet:  (...a) => console.log("[max.out ]", ...a),
    addHandler: () => {},
    MESSAGE_TYPES: { ALL: "all" }
  };
}
try {
  WSServer = require("ws").WebSocketServer;
} catch (e) {
  console.error("ws module not installed. Run `npm install` in this folder.");
  if (Max && Max.post) Max.post("ws module missing — run npm install inside the IMMER folder", "error");
}

// ── config (driven from the patch) ──────────────────────────────

const cfg = {
  // v2 defaults to 8081 so it can coexist with a v1 patch (which uses 8080)
  // on the same laptop. Override from the patch's Port number box if needed.
  port:           8081,
  durationMs:     20 * 60 * 1000, // 20 min default
  soloHoldMs:     15 * 1000,      // counts as a "solo" once held alone this long
  countInMs:      10 * 1000,      // delay between START and the piece actually beginning
  tickMs:         1000
};

// ── state ──────────────────────────────────────────────────────

const ROLES = { MUSIC: "music", DANCE: "dance", IDLE: "idle" };

// performers: name → record. Name is the stable key (case-insensitive lookup,
// but we keep the display casing as supplied).
const performers = new Map();
// name → WebSocket
const sockets    = new Map();

function freshPerformer(name) {
  return {
    name,
    role: ROLES.IDLE,
    // "lan"    — joined via the local Node-for-Max ws server on this machine
    // "remote" — joined via the cloud mu-relay (no entry in `sockets`;
    //            messages flow through cloudWs by `to: <name>`)
    // Defaults to "lan"; the cloud-inbound handler upgrades it to "remote"
    // for performers it learns about.
    kind: "lan",
    connected: false,
    msInMusic: 0,
    msInDance: 0,
    lastRoleChange: Date.now(),
    soloMusicMs: 0,
    soloDanceMs: 0,
    // Per-partner in-progress co-role accumulators. otherName → ms in the
    // current contiguous segment they've been in the same role. Resets to
    // 0 when either party leaves the role, unless the threshold was
    // already crossed (in which case the relationship moves to the
    // permanent dancedWith/playedWith set).
    pairMusicMs: {},
    pairDanceMs: {},
    dancedWith:    new Set(),
    playedWith:    new Set(),
    didMusicSolo:  false,
    didDanceSolo:  false
  };
}

// Performance transport state.
//   countingIn → started → (countdown hits zero) → ended
// `countingIn` and `started` are mutually exclusive; both false = idle.
let countingIn     = false;
let countInEndsAt  = 0;
let started        = false;
let startedAt      = 0;
let endsAt         = 0;
let lastTick       = Date.now();
let tickTimer      = null;
let heartbeatTimer = null;
// Heartbeat sweep period. We ping each client every HEARTBEAT_MS; if a
// client hasn't responded with a pong by the next sweep, we terminate it.
// Worst-case detection of a phantom (phone in airplane mode, dead OS
// network stack) is therefore 2 * HEARTBEAT_MS. 15s is a common default.
const HEARTBEAT_MS = 15000;

// ── ip discovery (for the QR / URL we hand to performers) ──────

function lanIp() {
  const ifs = os.networkInterfaces();
  const candidates = [];
  Object.keys(ifs).forEach(k => {
    (ifs[k] || []).forEach(addr => {
      if (addr.family === "IPv4" && !addr.internal) {
        // Prefer en0/en1-style names; collect everything else as fallback.
        candidates.push({ name: k, addr: addr.address });
      }
    });
  });
  if (candidates.length === 0) return "127.0.0.1";
  candidates.sort((a, b) => {
    const score = n => (n.name.startsWith("en") ? 0 : 1);
    return score(a) - score(b);
  });
  return candidates[0].addr;
}

function publicUrl() {
  return `http://${lanIp()}:${cfg.port}/`;
}

// ── http server ────────────────────────────────────────────────

const PUBLIC_DIR = path.join(__dirname, "public");

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js":   "application/javascript; charset=utf-8",
  ".css":  "text/css; charset=utf-8",
  ".svg":  "image/svg+xml",
  ".png":  "image/png",
  ".ico":  "image/x-icon"
};

function serveStatic(req, res) {
  let urlPath = req.url.split("?")[0];
  if (urlPath === "/" || urlPath === "") urlPath = "/index.html";
  // Reject path traversal up-front.
  if (urlPath.indexOf("..") !== -1) {
    res.writeHead(400); res.end("bad path"); return;
  }
  const full = path.join(PUBLIC_DIR, urlPath);
  fs.readFile(full, (err, buf) => {
    if (err) { res.writeHead(404); res.end("not found"); return; }
    const ext = path.extname(full).toLowerCase();
    // Strong no-cache: every page load must hit the server and the user
    // must re-enter their name. Otherwise iOS Safari et al. will gleefully
    // serve a stale index.html (or even a stale JS bundle) from disk and
    // different phones end up rendering different versions of the lobby.
    res.writeHead(200, {
      "Content-Type":  MIME[ext] || "application/octet-stream",
      "Cache-Control": "no-store, no-cache, must-revalidate, max-age=0",
      "Pragma":        "no-cache",
      "Expires":       "0"
    });
    res.end(buf);
  });
}

// httpServer and wss are recreated on every startServer() call so that
// `setport` (and any future restart) gets clean Node instances rather than
// relying on .listen() being callable after .close() — which is unreliable
// across Node versions.
let httpServer = null;
let wss        = null;

function createHttpServer() {
  return http.createServer((req, res) => {
    if (req.url === "/health") {
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify({
        ok: true,
        performers: performers.size,
        started,
        remaining: started ? Math.max(0, endsAt - Date.now()) : cfg.durationMs
      }));
      return;
    }
    serveStatic(req, res);
  });
}

// All per-connection handler wiring, factored out so we can reattach it to
// a fresh wss instance after a port change.
function attachWsHandlers(ws) {
  ws.isAlive = true;
  ws.on("pong", () => { ws.isAlive = true; });
  ws.on("message", (raw) => {
    let msg;
    try { msg = JSON.parse(String(raw)); } catch (_) { return; }
    handleClientMessage(ws, msg);
  });
  ws.on("close", () => {
    // Find the name attached to this socket and disconnect them. Do NOT
    // call removePerformer here — that would wipe accumulated time,
    // pairings, and solo flags. A phone locking its screen for ten
    // seconds shouldn't cost Anna her two music solos. (See CLAUDE.md.)
    //
    // If this socket was orphaned by a duplicate-name join, it won't
    // appear in `sockets` (the new socket overwrote the entry) so the
    // lookup returns null and we correctly don't disconnect the new one.
    let goneName = null;
    sockets.forEach((sock, name) => { if (sock === ws) goneName = name; });
    if (goneName) disconnectPerformer(goneName);
  });
  sendTo(ws, snapshotFor(null));
}

// Phantom-connection sweep: a phone that drops off the network without a
// graceful close (airplane mode, OS network-stack hang, kernel kill) leaves
// the server-side socket "open" forever. Without this, accumulateTime
// would keep crediting time and pairings to a performer who isn't there.
function heartbeat() {
  if (!wss) return;
  wss.clients.forEach((ws) => {
    if (ws.isAlive === false) {
      // No pong since last sweep → consider it dead. terminate() fires the
      // close event, which routes through disconnectPerformer — solo flags,
      // pairings, and time totals are preserved per the Anna-bug rule.
      try { ws.terminate(); } catch (_) {}
      return;
    }
    ws.isAlive = false;
    try { ws.ping(); } catch (_) {}
  });
}

function handleClientMessage(ws, msg) {
  if (!msg || !msg.type) return;
  if (msg.type === "join") {
    const name = String(msg.name || "").trim();
    if (!name) { sendTo(ws, { type: "error", message: "name required" }); return; }
    addPerformer(name, ws);
    sendTo(ws, { type: "joined", name });
  }
  else if (msg.type === "role") {
    const name = String(msg.name || "").trim();
    const role = String(msg.role || "").trim();
    if (!performers.has(name)) return;
    if (!started) return; // role changes only count once the piece has started
    setRole(name, role === "music" ? ROLES.MUSIC : role === "dance" ? ROLES.DANCE : ROLES.IDLE);
  }
  else if (msg.type === "leave") {
    const name = String(msg.name || "").trim();
    removePerformer(name);
  }
  else if (msg.type === "start") {
    // Performers can kick off the piece from any device; same code path
    // as the patch's START button.
    beginCountIn();
  }
  broadcastSnapshot();
}

function sendTo(ws, obj) {
  if (ws && ws.readyState === 1) ws.send(JSON.stringify(obj));
}

function broadcastSnapshot() {
  if (wss) {
    // Iterate wss.clients (NOT just the `performers` map) so that connected
    // lobby viewers — clients who've opened the page but haven't joined yet —
    // also receive roster / count-in / start snapshots. Otherwise an unjoined
    // phone sees a stale roster forever until it joins. The personalized
    // "you" field is filled in only for sockets that map back to a performer.
    const wsToName = new Map();
    sockets.forEach((ws, name) => wsToName.set(ws, name));
    wss.clients.forEach((ws) => {
      if (ws.readyState !== 1) return;
      sendTo(ws, snapshotFor(wsToName.get(ws) || null));
    });
  }
  // Cloud-side: send a personalized snapshot to each connected remote
  // performer (directed by `to`), and a generic perform-scope snapshot for
  // unjoined cloud lobby viewers. Same rationale as the wss.clients iteration
  // above — a remote phone that opened the URL but hasn't typed a name yet
  // still needs roster updates.
  if (cloudWs && cloudReady) {
    performers.forEach(p => {
      if (p.kind !== "remote") return;
      try { cloudWs.send(JSON.stringify(Object.assign({ to: p.name }, snapshotFor(p.name)))); } catch (_) {}
    });
    try { cloudWs.send(JSON.stringify(Object.assign({ toRole: "perform" }, snapshotFor(null)))); } catch (_) {}
  }
}

// ── state mutations ────────────────────────────────────────────

function addPerformer(name, ws) {
  // If the same name reconnects, keep their accumulated stats — that's the
  // whole point of using the name as a stable identity key. A WebSocket
  // disconnect (phone lock, tab background, wifi blip) must not cost
  // anyone their pairings, time totals, or completed-solo flags.
  if (!performers.has(name)) {
    performers.set(name, freshPerformer(name));
    Max.outlet("performer", "add", name);
  }
  const p     = performers.get(name);
  const oldWs = sockets.get(name);
  p.connected = true;
  // Overwrite the sockets entry BEFORE closing the old socket. Order
  // matters: the old socket's close handler iterates `sockets` looking for
  // its own entry — since the entry now points to the new ws, it won't
  // find itself, and disconnectPerformer is correctly not called.
  sockets.set(name, ws);
  if (oldWs && oldWs !== ws) {
    // Someone joined under this name from a second device (or refreshed
    // before the old socket was reaped). Close the orphan so it stops
    // hanging in the server with no path back to the user.
    try { oldWs.close(); } catch (_) {}
  }
  Max.outlet("performer", "role", name, p.role);
  sendRoster();
  sendCoverage();
}

// Called when a WebSocket closes. Preserves the performer record (and all
// accumulated state); just drops the socket and forces the role to idle so
// we don't keep ticking time-in-role at someone whose phone is asleep.
function disconnectPerformer(name) {
  const p = performers.get(name);
  if (!p) return;
  if (started) accumulateTime(); // bank any time spent in the old role first
  p.role           = ROLES.IDLE;
  p.lastRoleChange = Date.now();
  p.connected      = false;
  sockets.delete(name);
  Max.outlet("performer", "role", name, p.role);
  sendCoverage();
}

// Explicit removal — used by the `clear` patch command and by clients that
// send an explicit {type:"leave"} message. Wipes the record entirely.
function removePerformer(name) {
  if (!performers.has(name)) return;
  performers.delete(name);
  sockets.delete(name);
  Max.outlet("performer", "remove", name);
  sendRoster();
  sendCoverage();
}

function setRole(name, role) {
  const p = performers.get(name);
  if (!p) return;
  // Accumulate time in the prior role up to this moment, then switch.
  accumulateTime();
  p.role = role;
  p.lastRoleChange = Date.now();
  Max.outlet("performer", "role", name, role);
  sendCoverage();
}

// Add elapsed ms since lastTick into per-performer counters, update pairings,
// and detect crossing the solo threshold.
function accumulateTime() {
  const now = Date.now();
  if (!started) { lastTick = now; return; }
  const dt = Math.max(0, now - lastTick);
  if (dt === 0) return;

  const musicians = [];
  const dancers   = [];
  performers.forEach(p => {
    if (p.role === ROLES.MUSIC) musicians.push(p);
    else if (p.role === ROLES.DANCE) dancers.push(p);
  });

  musicians.forEach(p => p.msInMusic += dt);
  dancers.forEach(  p => p.msInDance += dt);

  // Pair-hold: a pairing only counts as "played-with" / "danced-with" once
  // the two performers have been in the same role together for at least
  // cfg.soloHoldMs. A brief overlap (someone enters dance, someone else
  // steps out a few seconds later) doesn't qualify. Same threshold as solo
  // so there's one config knob for "minimum meaningful interaction time".
  tickPairHold(musicians, "pairMusicMs", "playedWith");
  tickPairHold(dancers,   "pairDanceMs", "dancedWith");

  function tickPairHold(group, accumField, lockField) {
    const inGroup = new Set(group.map(p => p.name));
    // Increment counters for every ordered pair currently in this role
    // group (only for pairs not yet locked in).
    for (let i = 0; i < group.length; i++) {
      const a = group[i];
      for (let j = 0; j < group.length; j++) {
        if (i === j) continue;
        const b = group[j];
        if (a[lockField].has(b.name)) continue;
        a[accumField][b.name] = (a[accumField][b.name] || 0) + dt;
        if (a[accumField][b.name] >= cfg.soloHoldMs) {
          a[lockField].add(b.name);
          // Mirror to b — their counter will cross on the same tick, but
          // be defensive in case of drift / role flicker.
          const op = performers.get(b.name);
          if (op) op[lockField].add(a.name);
          delete a[accumField][b.name];
        }
      }
    }
    // Reset partial counters for pairs that aren't co-roled this tick.
    // A leaves music → both A's and B's in-progress counters for each other
    // drop to zero. Already-locked-in pairs in `lockField` aren't affected.
    performers.forEach(p => {
      Object.keys(p[accumField]).forEach(other => {
        if (!inGroup.has(p.name) || !inGroup.has(other)) {
          delete p[accumField][other];
        }
      });
    });
  }

  // Solo accumulation + threshold detection.
  if (musicians.length === 1) {
    const p = musicians[0];
    p.soloMusicMs += dt;
    if (!p.didMusicSolo && p.soloMusicMs >= cfg.soloHoldMs) {
      p.didMusicSolo = true;
      Max.outlet("status", `${p.name} completed a music solo`);
    }
  } else {
    // Reset partial credit if they leave the solo state without crossing
    // the hold threshold. Once didMusicSolo is true it stays true.
    performers.forEach(p => { if (!p.didMusicSolo) p.soloMusicMs = 0; });
  }
  if (dancers.length === 1) {
    const p = dancers[0];
    p.soloDanceMs += dt;
    if (!p.didDanceSolo && p.soloDanceMs >= cfg.soloHoldMs) {
      p.didDanceSolo = true;
      Max.outlet("status", `${p.name} completed a dance solo`);
    }
  } else {
    performers.forEach(p => { if (!p.didDanceSolo) p.soloDanceMs = 0; });
  }

  lastTick = now;
}

// ── coverage / snapshot computation ────────────────────────────

function allNames() { return Array.from(performers.keys()); }

function buildCoverage() {
  const names = allNames();
  const now   = Date.now();
  const perPerformer = {};
  names.forEach(n => {
    const p = performers.get(n);
    const others = names.filter(x => x !== n);
    perPerformer[n] = {
      role:             p.role,
      msInMusic:        p.msInMusic,
      msInDance:        p.msInDance,
      msSinceChange:    Math.max(0, now - p.lastRoleChange),
      notDancedWith:    others.filter(x => !p.dancedWith.has(x)),
      notPlayedWith:    others.filter(x => !p.playedWith.has(x)),
      didMusicSolo:     p.didMusicSolo,
      didDanceSolo:     p.didDanceSolo
    };
  });
  const needsMusicSolo = names.filter(n => !performers.get(n).didMusicSolo);
  const needsDanceSolo = names.filter(n => !performers.get(n).didDanceSolo);
  return { perPerformer, needsMusicSolo, needsDanceSolo };
}

function snapshotFor(viewerName) {
  const cov = buildCoverage();
  const remainingMs       = started ? Math.max(0, endsAt - Date.now()) : cfg.durationMs;
  const countInRemainingMs = countingIn ? Math.max(0, countInEndsAt - Date.now()) : 0;
  const out = {
    type:        "snapshot",
    started,
    countingIn,
    countInRemainingMs,
    countInMs:   cfg.countInMs,
    remainingMs,
    durationMs:  cfg.durationMs,
    soloHoldMs:  cfg.soloHoldMs,
    roster:      allNames(),
    needsMusicSolo: cov.needsMusicSolo,
    needsDanceSolo: cov.needsDanceSolo
  };
  if (viewerName && cov.perPerformer[viewerName]) {
    out.you = Object.assign({ name: viewerName }, cov.perPerformer[viewerName]);
  }
  // Also include lightweight currently-on-stage info so clients can render
  // the cohort even if their personal record is empty.
  out.currently = {
    music: allNames().filter(n => performers.get(n).role === ROLES.MUSIC),
    dance: allNames().filter(n => performers.get(n).role === ROLES.DANCE),
    idle:  allNames().filter(n => performers.get(n).role === ROLES.IDLE)
  };
  return out;
}

function sendRoster() {
  Max.outlet.apply(Max, ["roster"].concat(allNames()));
  pushCellblock();
}

function sendCoverage() {
  Max.outlet("coverage", JSON.stringify(buildCoverage()));
  pushCellblock();
}

// Render the roster as direct jit.cellblock messages, so the patch can
// route them straight to a [jit.cellblock] with no scripting glue.
//   columns: # | Name | Role | Since | Music | Dance | Played-w | Danced-w | Solo
function pushCellblock() {
  const names = allNames();
  const now   = Date.now();
  const rows  = names.length + 1; // +1 header
  Max.outlet("cell", "rows",  rows);
  Max.outlet("cell", "cols",  9);
  Max.outlet("cell", "clear");
  Max.outlet("cell", "col", 0, "width",  28);
  Max.outlet("cell", "col", 1, "width", 110);
  Max.outlet("cell", "col", 2, "width",  60);
  Max.outlet("cell", "col", 3, "width",  56);
  Max.outlet("cell", "col", 4, "width",  56);
  Max.outlet("cell", "col", 5, "width",  56);
  Max.outlet("cell", "col", 6, "width",  56);
  Max.outlet("cell", "col", 7, "width",  56);
  Max.outlet("cell", "col", 8, "width",  46);
  Max.outlet("cell", "set", 0, 0, "#");
  Max.outlet("cell", "set", 1, 0, "Name");
  Max.outlet("cell", "set", 2, 0, "Role");
  Max.outlet("cell", "set", 3, 0, "Since");
  Max.outlet("cell", "set", 4, 0, "Music");
  Max.outlet("cell", "set", 5, 0, "Dance");
  Max.outlet("cell", "set", 6, 0, "Played");
  Max.outlet("cell", "set", 7, 0, "Danced");
  Max.outlet("cell", "set", 8, 0, "Solo");
  const N = names.length - 1;
  names.forEach((n, i) => {
    const p = performers.get(n);
    Max.outlet("cell", "set", 0, i + 1, String(i + 1));
    Max.outlet("cell", "set", 1, i + 1, p.connected ? n : n + " *");
    Max.outlet("cell", "set", 2, i + 1, p.connected ? p.role : "offline");
    Max.outlet("cell", "set", 3, i + 1, fmtMS(now - p.lastRoleChange));
    Max.outlet("cell", "set", 4, i + 1, fmtMS(p.msInMusic));
    Max.outlet("cell", "set", 5, i + 1, fmtMS(p.msInDance));
    // "Played" = how many of the other performers they've played music with.
    Max.outlet("cell", "set", 6, i + 1, `${p.playedWith.size}/${Math.max(0,N)}`);
    Max.outlet("cell", "set", 7, i + 1, `${p.dancedWith.size}/${Math.max(0,N)}`);
    const solo = (p.didMusicSolo ? "M" : "·") + (p.didDanceSolo ? "D" : "·");
    Max.outlet("cell", "set", 8, i + 1, solo);
  });
  Max.outlet("cell", "count", names.length);
}

function fmtMS(ms) {
  const s = Math.max(0, Math.round(ms / 1000));
  const m = Math.floor(s / 60);
  const r = s % 60;
  return m + ":" + (r < 10 ? "0" : "") + r;
}

// ── transport (start / stop / reset) ───────────────────────────

function beginCountIn() {
  if (countingIn || started) return;
  if (cfg.countInMs <= 0) { actuallyStartPiece(); return; }
  countingIn    = true;
  countInEndsAt = Date.now() + cfg.countInMs;
  Max.outlet("status", `Count-in — ${Math.round(cfg.countInMs / 1000)}s`);
  Max.outlet("countdown", Math.round(cfg.countInMs / 1000));
  broadcastSnapshot();
}

function actuallyStartPiece() {
  countingIn = false;
  started    = true;
  startedAt  = Date.now();
  endsAt     = startedAt + cfg.durationMs;
  lastTick   = startedAt;
  // Reset role-time + solo + pair accumulators so a fresh run is clean.
  performers.forEach(p => {
    p.role           = ROLES.IDLE;
    p.msInMusic      = 0;
    p.msInDance      = 0;
    p.lastRoleChange = startedAt;
    p.soloMusicMs    = 0;
    p.soloDanceMs    = 0;
    p.pairMusicMs    = {};
    p.pairDanceMs    = {};
    p.dancedWith     = new Set();
    p.playedWith     = new Set();
    p.didMusicSolo   = false;
    p.didDanceSolo   = false;
  });
  Max.outlet("status", `Started — ${Math.round(cfg.durationMs/1000)}s, ${performers.size} performers`);
  Max.outlet("countdown", Math.round(cfg.durationMs / 1000));
  broadcastSnapshot();
  sendCoverage();
}

function stopPiece() {
  if (!started && !countingIn) return;
  const wasRunning = started;
  if (started) accumulateTime();
  countingIn = false;
  started    = false;
  Max.outlet("status", wasRunning ? "Stopped" : "Count-in cancelled");
  broadcastSnapshot();
}

function resetState() {
  countingIn = false;
  started    = false;
  performers.forEach(p => {
    p.role           = ROLES.IDLE;
    p.msInMusic      = 0;
    p.msInDance      = 0;
    p.lastRoleChange = Date.now();
    p.soloMusicMs    = 0;
    p.soloDanceMs    = 0;
    p.pairMusicMs    = {};
    p.pairDanceMs    = {};
    p.dancedWith     = new Set();
    p.playedWith     = new Set();
    p.didMusicSolo   = false;
    p.didDanceSolo   = false;
  });
  Max.outlet("status", "Reset");
  Max.outlet("countdown", Math.round(cfg.durationMs / 1000));
  broadcastSnapshot();
  sendCoverage();
}

// ── per-second tick ────────────────────────────────────────────

function tick() {
  // Count-in phase: drive the countdown down, then roll into the piece.
  if (countingIn) {
    const remainingMs = countInEndsAt - Date.now();
    if (remainingMs <= 0) { actuallyStartPiece(); return; }
    Max.outlet("countdown", Math.max(0, Math.round(remainingMs / 1000)));
    broadcastSnapshot(); // count-in is short — push every tick so clients stay in sync
    return;
  }
  if (!started) return;
  accumulateTime();
  const remainingMs = endsAt - Date.now();
  Max.outlet("countdown", Math.max(0, Math.round(remainingMs / 1000)));
  if (remainingMs <= 0) {
    started = false;
    Max.outlet("status", "Performance complete");
    Max.outlet("complete", "bang");
    broadcastSnapshot();
    return;
  }
  // Every tick: repaint the patch cellblock so the "Since" / time columns
  // stay live even when no role events fire. Clients update msInRole locally
  // and only need a fresh snapshot every couple of seconds.
  pushCellblock();
  if ((Date.now() - startedAt) % 2000 < cfg.tickMs) {
    broadcastSnapshot();
    sendCoverage();
  }
}

// ── boot ───────────────────────────────────────────────────────

function startServer() {
  // Fresh instances every time — required for setport to actually work,
  // because httpServer.listen() after .close() is not guaranteed across
  // Node versions.
  httpServer = createHttpServer();
  httpServer.on("error", (err) => {
    Max.post(`HTTP server error: ${err.message}`, "error");
    Max.outlet("status", `HTTP error: ${err.message}`);
  });
  httpServer.listen(cfg.port, () => {
    const url = publicUrl();
    Max.post(`IMMER server listening at ${url}`);
    Max.outlet("url", url);
    Max.outlet("status", `Listening on ${url}`);
  });
  if (WSServer) {
    wss = new WSServer({ server: httpServer });
    wss.on("connection", attachWsHandlers);
  }
  if (tickTimer)      clearInterval(tickTimer);
  if (heartbeatTimer) clearInterval(heartbeatTimer);
  tickTimer      = setInterval(tick,      cfg.tickMs);
  heartbeatTimer = setInterval(heartbeat, HEARTBEAT_MS);
}

function stopServer() {
  if (tickTimer)      { clearInterval(tickTimer);      tickTimer = null; }
  if (heartbeatTimer) { clearInterval(heartbeatTimer); heartbeatTimer = null; }
  if (wss) {
    // Explicitly terminate clients first — wss.close() alone doesn't
    // guarantee in-flight client sockets are closed on every Node version.
    // Each terminate() triggers the close event, which preserves state via
    // disconnectPerformer.
    wss.clients.forEach((ws) => { try { ws.terminate(); } catch (_) {} });
    try { wss.close(); } catch (_) {}
    wss = null;
  }
  if (httpServer) {
    try { httpServer.close(); } catch (_) {}
    httpServer = null;
  }
}

// ── max handlers (called by messages sent to node.script's inlet) ──

Max.addHandler("setduration", (mins) => {
  const m = Math.max(1, Number(mins) || 0);
  cfg.durationMs = Math.round(m * 60 * 1000);
  if (started) {
    // Mid-piece changes recompute the end time so the conductor isn't
    // surprised by a silent ignore. Treat new duration as total length:
    // if the new endsAt is in the past, the piece will end on the next
    // tick — that's the user's call.
    endsAt = startedAt + cfg.durationMs;
    Max.outlet("countdown", Math.max(0, Math.round((endsAt - Date.now()) / 1000)));
  } else {
    Max.outlet("countdown", Math.round(cfg.durationMs / 1000));
  }
  Max.post(`duration set to ${m} min`);
});

Max.addHandler("setsolohold", (secs) => {
  cfg.soloHoldMs = Math.max(1, Number(secs) || 1) * 1000;
  Max.post(`solo-hold threshold set to ${cfg.soloHoldMs/1000}s`);
});

Max.addHandler("setcountin", (secs) => {
  cfg.countInMs = Math.max(0, Number(secs) || 0) * 1000;
  Max.post(`count-in set to ${cfg.countInMs/1000}s`);
});

Max.addHandler("setport", (p) => {
  const port = Math.max(1, Math.min(65535, Number(p) || 0));
  if (port === cfg.port) return;
  if (started || countingIn) {
    // A restart drops every connected client (their location.host points to
    // the old port forever — they'd never reconnect). Don't let the
    // conductor accidentally torpedo a running piece by twitching a number.
    Max.outlet("status", `Port change refused — stop the piece first`);
    Max.post("setport refused: piece is running");
    return;
  }
  cfg.port = port;
  Max.post(`port set to ${port} — restarting server`);
  stopServer();
  startServer();
  // Re-announce the new LAN URL to the relay so /lan/<piece>/<room> stays
  // accurate. No-op if cloud isn't connected.
  announceLanUrl();
});

Max.addHandler("start",  () => beginCountIn());
Max.addHandler("stop",   () => stopPiece());
Max.addHandler("reset",  () => resetState());

Max.addHandler("clear",  () => {
  performers.clear();
  sockets.forEach((ws) => { try { ws.close(); } catch (_) {} });
  sockets.clear();
  resetState();
  sendRoster();
});

Max.addHandler("ip",     () => Max.outlet("url", publicUrl()));
Max.addHandler("status", () => Max.outlet("status", `${performers.size} performers, ${started ? "running" : "stopped"}`));

// ── cloud bridge (Max ↔ shared CF Worker relay) ─────────────────
//
// Optional: lets this LAN server also expose the same room to remote
// performers over the internet via the generic `mu-relay` Cloudflare
// Worker (deployed once, shared by every piece built on the
// multi-user-template). We open ONE outbound WebSocket as the "host" of
// a (piece, room) pair; the relay routes:
//
//   host  → broadcasts to all remote performers (no audience in IMMER)
//   host  → directed messages (snapshot, joined, error) by `to: <name>`
//   relay → us:  remote performer messages annotated with fromRole:"perform"
//
// LAN performers and remote performers share the same `performers` map.
// Remote performers carry `kind: "remote"`; LAN performers carry
// `kind: "lan"`. Disconnect/state-preservation semantics (Anna-bug rule)
// apply to both.

let WSClient = null;
try { WSClient = require("ws").WebSocket; } catch (_) {}

let cloudWs          = null;
let cloudReady       = false;
let cloudReconnTimer = null;
let cloudClosing     = false; // distinguish user-requested disconnect from drops

const cloudCfg = {
  url:   "",                                  // wss://mu-relay.<sub>.workers.dev
  piece: "immer_v2",
  room:  "main",
  // Static-site base where the v2 client (public/index.html) is hosted.
  // Empty by default — v2 doesn't ship a hosted static mirror. The patch
  // shows a placeholder; the operator can paste their own host if they
  // host the client somewhere (e.g. a Cloudflare tunnel pointing at the
  // LAN server's HTTP port).
  siteBase: ""
};

function emitCloudStatus(text)    { Max.outlet("cloud", "status", text); }
function emitCloudConnected(flag) { Max.outlet("cloud", "connected", flag ? 1 : 0); }

function buildCloudWsUrl() {
  if (!cloudCfg.url) return null;
  const trimmed = cloudCfg.url.replace(/\/+$/, "");
  return `${trimmed}/mu/${encodeURIComponent(cloudCfg.piece)}/${encodeURIComponent(cloudCfg.room)}/host`;
}

function emitShareUrls() {
  if (!cloudCfg.url || !cloudCfg.piece || !cloudCfg.room || !cloudCfg.siteBase) {
    Max.outlet("cloud", "performurl", "(set Cloud URL, Piece, Room, Site base)");
    return;
  }
  const base    = cloudCfg.siteBase.replace(/\/+$/, "/");
  const encoded = encodeURIComponent(cloudCfg.url);
  const piece   = encodeURIComponent(cloudCfg.piece);
  const room    = encodeURIComponent(cloudCfg.room);
  Max.outlet("cloud", "performurl", `${base}?cloud=${encoded}&piece=${piece}&room=${room}`);
}

function cloudConnect() {
  if (!WSClient)     { emitCloudStatus("cloud disabled — ws module not loaded"); return; }
  if (!cloudCfg.url) { emitCloudStatus("set cloud URL first"); return; }
  cloudDisconnect(true /* silent */);
  cloudClosing = false;
  const u = buildCloudWsUrl();
  emitCloudStatus(`connecting → ${u}`);
  let sock;
  try { sock = new WSClient(u); }
  catch (e) { emitCloudStatus(`connect failed: ${e.message}`); return; }
  cloudWs = sock;
  sock.on("open", () => {
    cloudReady = true;
    emitCloudConnected(true);
    emitCloudStatus(`cloud host live — ${cloudCfg.piece}:${cloudCfg.room}`);
    // Announce our current LAN URL to the relay so a static page can
    // build a "Local mode" link without knowing the laptop's IP. The
    // relay stores this in the DO and redirects /lan/<piece>/<room>
    // GET requests to it. Re-sent on setport (see announceLanUrl).
    announceLanUrl();
    // Push the current snapshot immediately so any waiting remote
    // performers hear about us as soon as we attach.
    broadcastSnapshot();
  });
  sock.on("message", (raw) => {
    let msg;
    try { msg = JSON.parse(String(raw)); } catch (_) { return; }
    handleCloudInbound(msg);
  });
  sock.on("close", () => {
    cloudReady = false;
    if (cloudWs === sock) cloudWs = null;
    emitCloudConnected(false);
    if (cloudClosing) { emitCloudStatus("cloud disconnected (user requested)"); return; }
    emitCloudStatus("cloud connection lost — retrying in 3s");
    cloudReconnTimer = setTimeout(cloudConnect, 3000);
  });
  sock.on("error", (err) => {
    emitCloudStatus(`cloud error: ${err.message || err}`);
    // `close` fires after — let it handle the reconnect.
  });
}

// Send the current http://<lan-ip>:<port>/ to the relay, where it's stored
// per-room and served to any GET /lan/<piece>/<room> request as a 302.
// Safe to call when not connected (no-op then) — called from sock.on("open")
// and from setport after a successful restart.
function announceLanUrl() {
  if (!cloudWs || !cloudReady) return;
  try { cloudWs.send(JSON.stringify({ type: "host-info", lanUrl: publicUrl() })); } catch (_) {}
}

function cloudDisconnect(silent) {
  cloudClosing = true;
  if (cloudReconnTimer) { clearTimeout(cloudReconnTimer); cloudReconnTimer = null; }
  if (cloudWs) {
    try { cloudWs.close(); } catch (_) {}
    cloudWs = null;
  }
  cloudReady = false;
  if (!silent) {
    emitCloudConnected(false);
    emitCloudStatus("cloud disconnected");
  }
}

// Relay → host. Everything inbound from the cloud is annotated with
// `fromRole` (perform — audience is out of scope for IMMER) and `from`
// (the performer's display name).
function handleCloudInbound(msg) {
  if (!msg || !msg.type) return;
  if (msg.type === "mu-hello") {
    emitCloudStatus(`relay handshake — counts ${JSON.stringify(msg.connections)}`);
    return;
  }
  if (msg.type === "mu-presence") {
    // A relay-side perform socket closed. Disconnect (don't remove) the
    // matching performer so their accumulated state survives — same rule
    // as a LAN ws close.
    if (msg.event === "leave" && msg.role === "perform" && msg.name) {
      const p = performers.get(msg.name);
      if (p && p.kind === "remote") disconnectPerformer(msg.name);
    }
    return;
  }
  if (msg.fromRole !== "perform") return; // ignore audience / unknown
  handleRemotePerformInbound(msg);
}

function handleRemotePerformInbound(msg) {
  const name = String(msg.from || msg.name || "").trim();
  if (!name) return;

  if (msg.type === "join") {
    // First time we hear from this remote performer (or they reconnected).
    // Create a fresh record only if none exists — keeps accumulated time,
    // pairings, and solo flags across cloud drops, same as LAN.
    if (!performers.has(name)) {
      const p = freshPerformer(name);
      p.kind = "remote";
      performers.set(name, p);
      Max.outlet("performer", "add", name);
    }
    const p = performers.get(name);
    p.kind      = "remote";
    p.connected = true;
    Max.outlet("performer", "role", name, p.role);
    sendRoster();
    sendCoverage();
    // Personalized acknowledgement back through the relay.
    if (cloudWs && cloudReady) {
      try { cloudWs.send(JSON.stringify({ to: name, type: "joined", name })); } catch (_) {}
      try { cloudWs.send(JSON.stringify(Object.assign({ to: name }, snapshotFor(name)))); } catch (_) {}
    }
    return;
  }

  if (!performers.has(name)) return;

  if (msg.type === "role") {
    if (!started) return;
    const role = String(msg.role || "").trim();
    setRole(name, role === "music" ? ROLES.MUSIC : role === "dance" ? ROLES.DANCE : ROLES.IDLE);
  } else if (msg.type === "leave") {
    removePerformer(name);
  } else if (msg.type === "start") {
    beginCountIn();
  }
  broadcastSnapshot();
}

// ── Max handlers for the cloud bridge ───────────────────────────

Max.addHandler("setcloudurl", (...args) => {
  cloudCfg.url = args.map(String).join(" ").trim();
  Max.post(`cloud URL → ${cloudCfg.url || "(empty)"}`);
  emitShareUrls();
});
Max.addHandler("setpiece", (...args) => {
  const s = args.map(String).join("-").trim();
  if (!/^[A-Za-z0-9_\-]+$/.test(s)) { emitCloudStatus("piece must match [A-Za-z0-9_-]"); return; }
  cloudCfg.piece = s;
  Max.post(`piece → ${s}`);
  emitShareUrls();
});
Max.addHandler("setroom", (...args) => {
  const s = args.map(String).join("-").trim() || "main";
  if (!/^[A-Za-z0-9_\-]+$/.test(s)) { emitCloudStatus("room must match [A-Za-z0-9_-]"); return; }
  cloudCfg.room = s;
  Max.post(`room → ${s}`);
  emitShareUrls();
});
Max.addHandler("setsitebase", (...args) => {
  cloudCfg.siteBase = args.map(String).join(" ").trim();
  Max.post(`site base → ${cloudCfg.siteBase || "(empty)"}`);
  emitShareUrls();
});
Max.addHandler("cloudon",     () => cloudConnect());
Max.addHandler("cloudoff",    () => cloudDisconnect(false));
Max.addHandler("cloudstatus", () => {
  emitCloudStatus(`url=${cloudCfg.url || "?"} piece=${cloudCfg.piece} room=${cloudCfg.room} connected=${cloudReady ? 1 : 0}`);
});

// Auto-boot the moment the script is loaded by node.script.
startServer();
emitShareUrls();

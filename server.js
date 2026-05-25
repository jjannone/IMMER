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
  port:           8080,
  durationMs:     20 * 60 * 1000, // 20 min default
  soloHoldMs:     15 * 1000,      // counts as a "solo" once held alone this long
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
    msInMusic: 0,
    msInDance: 0,
    lastRoleChange: Date.now(),
    soloMusicMs: 0,
    soloDanceMs: 0,
    dancedWith:    new Set(),
    playedWith:    new Set(),
    didMusicSolo:  false,
    didDanceSolo:  false
  };
}

// Performance transport state.
let started   = false;
let startedAt = 0;
let endsAt    = 0;
let lastTick  = Date.now();
let tickTimer = null;

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
    res.writeHead(200, { "Content-Type": MIME[ext] || "application/octet-stream" });
    res.end(buf);
  });
}

const httpServer = http.createServer((req, res) => {
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

// ── websocket server ───────────────────────────────────────────

let wss = null;
if (WSServer) {
  wss = new WSServer({ server: httpServer });
  wss.on("connection", (ws) => {
    ws.on("message", (raw) => {
      let msg;
      try { msg = JSON.parse(String(raw)); } catch (_) { return; }
      handleClientMessage(ws, msg);
    });
    ws.on("close", () => {
      // Find the name attached to this socket and unregister.
      let goneName = null;
      sockets.forEach((sock, name) => { if (sock === ws) goneName = name; });
      if (goneName) removePerformer(goneName);
    });
    // Send initial snapshot.
    sendTo(ws, snapshotFor(null));
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
  broadcastSnapshot();
}

function sendTo(ws, obj) {
  if (ws && ws.readyState === 1) ws.send(JSON.stringify(obj));
}

function broadcastSnapshot() {
  if (!wss) return;
  performers.forEach((rec, name) => {
    const ws = sockets.get(name);
    if (ws) sendTo(ws, snapshotFor(name));
  });
}

// ── state mutations ────────────────────────────────────────────

function addPerformer(name, ws) {
  // If the same name reconnects, keep their accumulated stats.
  if (!performers.has(name)) {
    performers.set(name, freshPerformer(name));
    Max.outlet("performer", "add", name);
  }
  sockets.set(name, ws);
  Max.outlet("performer", "role", name, performers.get(name).role);
  sendRoster();
  sendCoverage();
}

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

  // Pairings: every musician has now "played with" every other current musician;
  // every dancer has now "danced with" every other current dancer.
  for (let i = 0; i < musicians.length; i++) {
    for (let j = 0; j < musicians.length; j++) {
      if (i !== j) musicians[i].playedWith.add(musicians[j].name);
    }
  }
  for (let i = 0; i < dancers.length; i++) {
    for (let j = 0; j < dancers.length; j++) {
      if (i !== j) dancers[i].dancedWith.add(dancers[j].name);
    }
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
  const perPerformer = {};
  names.forEach(n => {
    const p = performers.get(n);
    const others = names.filter(x => x !== n);
    perPerformer[n] = {
      role:           p.role,
      msInMusic:      p.msInMusic,
      msInDance:      p.msInDance,
      notDancedWith:  others.filter(x => !p.dancedWith.has(x)),
      notPlayedWith:  others.filter(x => !p.playedWith.has(x)),
      didMusicSolo:   p.didMusicSolo,
      didDanceSolo:   p.didDanceSolo
    };
  });
  const needsMusicSolo = names.filter(n => !performers.get(n).didMusicSolo);
  const needsDanceSolo = names.filter(n => !performers.get(n).didDanceSolo);
  return { perPerformer, needsMusicSolo, needsDanceSolo };
}

function snapshotFor(viewerName) {
  const cov = buildCoverage();
  const remainingMs = started ? Math.max(0, endsAt - Date.now()) : cfg.durationMs;
  const out = {
    type:        "snapshot",
    started,
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
//   columns: # | Name | Role | Music | Dance | Played-w | Danced-w | Solo
function pushCellblock() {
  const names = allNames();
  const rows  = names.length + 1; // +1 header
  Max.outlet("cell", "rows",  rows);
  Max.outlet("cell", "cols",  8);
  Max.outlet("cell", "clear");
  Max.outlet("cell", "col", 0, "width",  28);
  Max.outlet("cell", "col", 1, "width", 110);
  Max.outlet("cell", "col", 2, "width",  60);
  Max.outlet("cell", "col", 3, "width",  56);
  Max.outlet("cell", "col", 4, "width",  56);
  Max.outlet("cell", "col", 5, "width",  56);
  Max.outlet("cell", "col", 6, "width",  56);
  Max.outlet("cell", "col", 7, "width",  46);
  Max.outlet("cell", "set", 0, 0, "#");
  Max.outlet("cell", "set", 1, 0, "Name");
  Max.outlet("cell", "set", 2, 0, "Role");
  Max.outlet("cell", "set", 3, 0, "Music");
  Max.outlet("cell", "set", 4, 0, "Dance");
  Max.outlet("cell", "set", 5, 0, "Played");
  Max.outlet("cell", "set", 6, 0, "Danced");
  Max.outlet("cell", "set", 7, 0, "Solo");
  const N = names.length - 1;
  names.forEach((n, i) => {
    const p = performers.get(n);
    Max.outlet("cell", "set", 0, i + 1, String(i + 1));
    Max.outlet("cell", "set", 1, i + 1, n);
    Max.outlet("cell", "set", 2, i + 1, p.role);
    Max.outlet("cell", "set", 3, i + 1, fmtMS(p.msInMusic));
    Max.outlet("cell", "set", 4, i + 1, fmtMS(p.msInDance));
    // "Played" = how many of the other performers they've played music with.
    Max.outlet("cell", "set", 5, i + 1, `${p.playedWith.size}/${Math.max(0,N)}`);
    Max.outlet("cell", "set", 6, i + 1, `${p.dancedWith.size}/${Math.max(0,N)}`);
    const solo = (p.didMusicSolo ? "M" : "·") + (p.didDanceSolo ? "D" : "·");
    Max.outlet("cell", "set", 7, i + 1, solo);
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

function startPiece() {
  if (started) return;
  started   = true;
  startedAt = Date.now();
  endsAt    = startedAt + cfg.durationMs;
  lastTick  = startedAt;
  // Reset role-time + solo accumulators so a fresh run is clean.
  performers.forEach(p => {
    p.role           = ROLES.IDLE;
    p.msInMusic      = 0;
    p.msInDance      = 0;
    p.lastRoleChange = startedAt;
    p.soloMusicMs    = 0;
    p.soloDanceMs    = 0;
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
  if (!started) return;
  accumulateTime();
  started = false;
  Max.outlet("status", "Stopped");
  broadcastSnapshot();
}

function resetState() {
  started = false;
  performers.forEach(p => {
    p.role           = ROLES.IDLE;
    p.msInMusic      = 0;
    p.msInDance      = 0;
    p.lastRoleChange = Date.now();
    p.soloMusicMs    = 0;
    p.soloDanceMs    = 0;
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
  if ((Date.now() - startedAt) % 2000 < cfg.tickMs) {
    // Push a snapshot to clients every ~2s so coverage stays fresh.
    broadcastSnapshot();
    sendCoverage();
  }
}

// ── boot ───────────────────────────────────────────────────────

function startServer() {
  httpServer.listen(cfg.port, () => {
    const url = publicUrl();
    Max.post(`IMMER server listening at ${url}`);
    Max.outlet("url", url);
    Max.outlet("status", `Listening on ${url}`);
  });
  httpServer.on("error", (err) => {
    Max.post(`HTTP server error: ${err.message}`, "error");
    Max.outlet("status", `HTTP error: ${err.message}`);
  });
  if (tickTimer) clearInterval(tickTimer);
  tickTimer = setInterval(tick, cfg.tickMs);
}

function stopServer() {
  if (tickTimer) { clearInterval(tickTimer); tickTimer = null; }
  if (wss) { try { wss.close(); } catch (_) {} }
  try { httpServer.close(); } catch (_) {}
}

// ── max handlers (called by messages sent to node.script's inlet) ──

Max.addHandler("setduration", (mins) => {
  const m = Math.max(1, Number(mins) || 0);
  cfg.durationMs = Math.round(m * 60 * 1000);
  if (!started) Max.outlet("countdown", Math.round(cfg.durationMs / 1000));
  Max.post(`duration set to ${m} min`);
});

Max.addHandler("setsolohold", (secs) => {
  cfg.soloHoldMs = Math.max(1, Number(secs) || 1) * 1000;
  Max.post(`solo-hold threshold set to ${cfg.soloHoldMs/1000}s`);
});

Max.addHandler("setport", (p) => {
  const port = Math.max(1, Math.min(65535, Number(p) || 0));
  if (port === cfg.port) return;
  cfg.port = port;
  Max.post(`port set to ${port} — restarting server`);
  stopServer();
  startServer();
});

Max.addHandler("start",  () => startPiece());
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

// Auto-boot the moment the script is loaded by node.script.
startServer();

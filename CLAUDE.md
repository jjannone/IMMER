# Working notes for Claude (and future contributors)

This file is the canonical home for project-specific lessons learned while
building IMMER. If you discover a non-obvious gotcha while working in this
repo — a Max attribute that silent-fails, a Node-for-Max quirk, a
WebSocket-on-LAN trap — **write it here**. Memory in `~/.claude/` is private
to one machine and invisible to anyone who clones the repo; knowledge
written here travels with the code.

---

## Patching lessons

### Hide formatter boxes (and their cables) that sit downstream of UI elements

**Rule:** if a box exists *solely* to format a value coming from an upstream
UI element — a `[setport $1]` message between a number box and `node.script`,
a `[start]` message between a button and `node.script` — set `"hidden": 1`
on the box and on every cable touching it. The locked-view of the patch
should show only the user-facing controls. Plumbing is for editors, not for
the conductor running the piece.

Applied throughout `immer.maxpat`:

- **Hidden message boxes:** `obj-msg-setport`, `obj-msg-setdur`,
  `obj-msg-setsolo`, `obj-msg-setcountin` (downstream of number boxes);
  `obj-msg-start`, `obj-msg-stop`, `obj-msg-reset`, `obj-msg-clear`
  (downstream of transport buttons).
- **Hidden cables:** every patchline whose source or destination is one of
  the above. Carries `"hidden": 1` on the patchline.

**When NOT to hide:**

- The UI element itself (number box, button, textedit, cellblock) — those
  are what the user clicks.
- A `[prepend set]` feeding a display comment — also infrastructure, but
  hide alongside the comment's incoming cable.
- A message box the user is *meant* to click — those stay visible.

**Schema:** the `hidden` flag is `1` (int), not `true`. It lives on the box
object next to `id`, `maxclass`, etc. For patchlines it lives directly inside
the `patchline` object alongside `source` / `destination`.

```json
{ "box": { "hidden": 1, "id": "obj-msg-setport", "maxclass": "message", ... } }
{ "patchline": { "hidden": 1, "source": [...], "destination": [...] } }
```

**Why bother with this in source rather than just locked-view:** the patch
is its own UI for the conductor at performance time. Visual clutter is
genuine friction during a piece — every hidden cable is one less line in
the eye when something goes wrong on stage.

### Textedit's left outlet emits `text <symbol>` by default — don't capture with `$1`

Wiring `[textedit] → [setfoo $1] → [node.script]` looks right and silently
does the wrong thing. By default `textedit` has `@outputmode 0` ("output as
messages"), which means typing `wss://example.com` and pressing return
emits the **list** `text wss://example.com` from its left outlet. `$1` in
the downstream message box captures the first atom — the literal symbol
`text` — and the actual value is lost. There's no error. The handler runs
with the wrong argument and the patch silently misbehaves.

This bit IMMER v2 once already: the cloud config textedit fed
`[setcloudurl $1]`, which stored `cloudCfg.url = "text"`, which produced
`buildCloudWsUrl() = "text/mu/immer_v2/main/host"` — `Invalid URL`.

Three valid fixes; pick whichever matches the situation:

- **Set `outputmode 1` on the textedit.** Output becomes a bare symbol;
  `$1` works as expected. Cleanest when the user is *meant* to edit the
  value at runtime.
- **`[route text]` between the textedit and the consumer.** Strips the
  `text` prefix and forwards the remainder. Useful when you can't change
  the textedit's attribute (e.g. you didn't author it).
- **Skip the textedit entirely and bake the value into a message fired
  by loadbang.** Right answer when the value is fixed configuration the
  user shouldn't be re-typing at performance time. This is what IMMER
  v2's `obj-def-cloudurl` / `obj-def-sitebase` / `obj-def-piece` /
  `obj-def-room` messages do.

The general principle: any Max object whose default output is a *list*
(not a bare value) silently breaks `$1`-style capture. Verify the output
format from the refpage before wiring `$N` against it — same discipline
as the "never write attribute names from memory" rule.

### Don't conclude a Max attribute "doesn't exist" from a truncated grep

When verifying whether an attribute or message exists on a Max object,
**read the whole refpage section, not a truncated `head`**.

Concrete example from this project's history: I claimed `@popup` was not a
valid `print` attribute and removed it from `immer.maxpat`. The user
corrected me — `popup` IS a real `print` attribute, opening the Max window
automatically when a message arrives. The "verification" that misled me was:

```bash
grep -E "attribute name|<method" print.maxref.xml | head -30
```

`head -30` cuts off before `popup` appears alphabetically. Concluding "the
attribute doesn't exist" from a truncated read is the same class of failure
as writing the name from memory — silent and confidence-inducing.

**How to verify properly:**

```bash
# either no head/tail at all:
grep "attribute name" print.maxref.xml

# or grep for the specific name:
grep '"popup"' print.maxref.xml

# or count to make sure your view is complete:
grep -c "<attribute " print.maxref.xml
```

Only assert "X is not a valid name" when you've seen the whole list. Same
discipline applies to messages, method names, CSS properties, anything
where a wrong name is silently accepted and quietly ignored.

---

## Project-specific gotchas

### "Disconnect" is not "leave" — keep performer records across socket drops

A phone disconnect is **not** the same event as a performer leaving the
ensemble. Screen lock, tab background, brief wifi blip, or a fresh reload
of the page all close the WebSocket — but the performer is still in the
piece. Their accumulated time, pairings, and completed-solo flags must
survive.

The bug this rule prevents (observed in a real run): Anna soloed twice,
her phone locked momentarily, the WebSocket closed and the server called
`removePerformer()` which deleted her record. On auto-rejoin she got a
fresh record — `didMusicSolo` reset to `false`, and "still needs a solo"
showed her name again. She soloed twice more, then locked her screen
again, then the cycle repeated.

**Correct lifecycle:**

| Event                              | Action                          |
|------------------------------------|---------------------------------|
| WebSocket `close` (drop)           | `disconnectPerformer(name)` — drop the socket, set `connected = false`, force role to `idle`, but keep the full record. |
| Client sends explicit `{type:"leave"}` | `removePerformer(name)` — fully delete. (Note: the current web client never sends this.) |
| Patch `clear` command              | `performers.clear()` — full wipe of everyone, used between pieces. |
| Reconnect with the same name       | `addPerformer` finds existing record, sets `connected = true`, attaches new socket. State preserved. |

**Why force role to idle on disconnect (rather than leaving them in their
last role):** the `accumulateTime()` loop ticks every second and keeps
adding `dt` to whichever role each performer is in. If Anna disconnects
while dancing, leaving her role as `dance` would keep crediting her with
dance time she isn't actually performing. Idle stops the accumulation
without affecting any historical state.

The cellblock renders disconnected performers as `Name *` with role
`offline` so the conductor can see at a glance who's dropped.

### WebSocket heartbeat is required — silence ≠ alive

`ws.on("close")` only fires when the TCP connection closes *cleanly*. A
phone in airplane mode, an OS network stack hang, or a kernel-killed
process leave the server-side socket "open" indefinitely. Without a
heartbeat the performer remains `connected: true`, `accumulateTime` keeps
crediting them with role time, and pairings get falsely recorded with
someone who isn't there.

The pattern in `server.js`:

```js
ws.isAlive = true;
ws.on("pong", () => { ws.isAlive = true; });

function heartbeat() {
  wss.clients.forEach((ws) => {
    if (ws.isAlive === false) { ws.terminate(); return; }
    ws.isAlive = false;
    try { ws.ping(); } catch (_) {}
  });
}
setInterval(heartbeat, 15000);
```

`terminate()` fires the `close` event, which routes through
`disconnectPerformer` — solo flags / pairings / time totals are preserved
per the Anna-bug rule. Worst-case phantom detection time is
2 × the heartbeat interval.

### Duplicate-name join must close the old socket — and order matters

If Alice opens the page on a second device (or refreshes before the old
socket times out) she'll trigger a second `addPerformer("Alice", newWs)`.
Without explicit handling the older socket is orphaned: still alive
server-side, no entry in `sockets`, no broadcasts reaching it. The user
on phone1 sees the page freeze with no error.

Correct sequence:

```js
const oldWs = sockets.get(name);
sockets.set(name, ws);             // overwrite FIRST
if (oldWs && oldWs !== ws) {
  try { oldWs.close(); } catch (_) {}   // then close the orphan
}
```

**Why overwrite before close:** the old socket's close handler iterates
`sockets` looking for its own reference. If we close it *before*
overwriting, that handler finds Alice's entry pointing at the old socket,
calls `disconnectPerformer("Alice")`, and we've just torpedoed the new
device's brand-new connection. After the overwrite, the handler iterates,
sees `sockets["Alice"] === newWs` (not the old one), `goneName` stays
null, no disconnect happens. The orphan is reaped cleanly.

### Mid-piece config mutations: act, don't silently ignore

`setduration` used to update `cfg.durationMs` but leave the running
`endsAt` untouched. The conductor twisting the Duration number box
mid-piece would see nothing happen — a silent ignore that's the same
class of bug as the Anna disconnect (config-visible value disagrees with
actual behaviour-driving value).

The current pattern:

```js
Max.addHandler("setduration", (mins) => {
  cfg.durationMs = Math.round(mins * 60 * 1000);
  if (started) {
    endsAt = startedAt + cfg.durationMs;  // act on the live piece
    Max.outlet("countdown", Math.max(0, Math.round((endsAt - Date.now()) / 1000)));
  } else {
    Max.outlet("countdown", Math.round(cfg.durationMs / 1000));
  }
});
```

For settings that genuinely can't be applied mid-run (like `setport`,
which would drop every connected client since their `location.host` is
fixed at page load), **refuse with a status message** rather than
silently accepting and confusing the user later:

```js
if (started || countingIn) {
  Max.outlet("status", `Port change refused — stop the piece first`);
  return;
}
```

The rule: a config mutation either takes effect, or surfaces a refusal.
Never both-the-display-says-X-and-the-behaviour-says-Y.

### Restart-friendly server lifecycle

`httpServer.listen()` after `.close()` is unreliable across Node versions
— some allow it, some leave the server un-listenable. Same with `wss` /
client-socket survival semantics. For any handler that needs to restart
the server (like `setport`), create **fresh** `http.createServer()` and
`new WSServer(...)` instances each time:

```js
let httpServer = null, wss = null;

function startServer() {
  httpServer = createHttpServer();
  httpServer.listen(cfg.port, ...);
  if (WSServer) {
    wss = new WSServer({ server: httpServer });
    wss.on("connection", attachWsHandlers);
  }
}

function stopServer() {
  wss && wss.clients.forEach((ws) => { try { ws.terminate(); } catch (_) {} });
  wss && wss.close(); wss = null;
  httpServer && httpServer.close(); httpServer = null;
}
```

Explicitly terminate clients before closing `wss` — `wss.close()` alone
doesn't guarantee in-flight client sockets are closed on every Node
version, and lingering sockets would survive into the next `startServer`
context where their handlers wouldn't make sense.

### Pair-hold threshold mirrors solo-hold (same knob, same idea)

A pairing only counts as *played-with* / *danced-with* once the two
performers have been in the same role together for at least
`cfg.soloHoldMs`. Without this, a brief overlap — someone enters dance,
someone else steps out a few seconds later — would falsely qualify as
"danced with", and the coverage lists would drain in a flurry of
meaningless transitions.

The pattern is the same as solo-hold but per-pair:

```js
// Each performer carries an in-progress accumulator per partner:
p.pairMusicMs = { otherName: msInCurrentSegment, ... }
p.pairDanceMs = { otherName: msInCurrentSegment, ... }

// Each tick, for every pair currently co-roled (and not yet locked in):
a[accumField][b.name] = (a[accumField][b.name] || 0) + dt;
if (a[accumField][b.name] >= cfg.soloHoldMs) {
  a[lockField].add(b.name);
  // mirror to b so the relationship is symmetric (b's counter also crosses
  // on the same tick, but mirror defensively)
  performers.get(b.name)[lockField].add(a.name);
  delete a[accumField][b.name];
}

// Pairs that aren't co-roled this tick reset to 0 (delete from accum).
// Already-locked pairs in lockField aren't affected.
```

We deliberately share `cfg.soloHoldMs` between solo and pair detection
rather than introducing a second config — the patch UI stays at one knob
labelled "Solo hold (sec)" which now means "minimum meaningful interaction
time". If a future user wants them separated, add `cfg.pairHoldMs` and a
second number box in the patch.

The pair counters live in `freshPerformer`, get reset in
`actuallyStartPiece` and `resetState` alongside the other run-scoped
accumulators, and are NOT touched by `disconnectPerformer` — the next
`accumulateTime` tick sees the disconnected performer's role as idle and
the per-tick reset step deletes their stale partner counters automatically.

### Broadcast to `wss.clients`, not just `performers`

`broadcastSnapshot` originally iterated the `performers` map and sent
updates only to sockets associated with joined performers. Unjoined
lobby viewers — anyone who had opened the page but not yet typed a name
— received exactly one snapshot at connect time and then nothing else.
Result: different phones rendered different "Already joined" lists
depending on when they happened to load the page, with no way to recover
short of re-joining.

The rule: state changes that affect everyone (roster grows/shrinks,
count-in fires, piece starts/ends) must reach every connected socket,
not just authenticated ones. Iterate `wss.clients`; look up the
personalized `you` data via a reverse socket→name map for whichever
clients have one.

```js
const wsToName = new Map();
sockets.forEach((ws, name) => wsToName.set(ws, name));
wss.clients.forEach((ws) => {
  if (ws.readyState !== 1) return;
  sendTo(ws, snapshotFor(wsToName.get(ws) || null));
});
```

### Fresh page load = fresh client state (no `localStorage`)

The client deliberately does NOT persist anything across page loads. A
hard refresh is the canonical "reset me" gesture — the user must re-enter
their name, and the only state that survives is whatever the server
holds. This avoids two failure modes:

1. **Phones rendering different "Already joined" lists** because each one
   prefilled its own remembered name and joined under it before others
   caught up.
2. **Stale name surviving a CLEAR**. If the conductor hits CLEAR mid-
   rehearsal and a phone has the old name in `localStorage`, the auto-
   prefill puts it back even though the server intends a wipe.

`myName` lives only in the script's memory (not storage) so that
WebSocket reconnects within the same page session — phone briefly sleeps,
socket drops — can still auto-rejoin without prompting. The moment the
user closes the tab or hard-refreshes, that goes away.

The HTML is also served with strict no-cache headers (`Cache-Control:
no-store, no-cache, must-revalidate`) AND a redundant `<meta>` equivalent
so iOS Safari can't quietly hand back a previous build of the page.
Without these, different devices were observed running materially
different versions of the lobby code at the same time.

### `node.script` outlet routing

The patch wires `node.script` to a single `[route performer roster countdown
status url coverage complete cell]` block. The selectors come from
`server.js` via `Max.outlet("<selector>", ...)`. If you add a new selector
in `server.js`, **add it to the route object** or the messages will fall
out the rightmost (unmatched) outlet and silently disappear.

### Comment box accepts multi-symbol `set`

The URL and status comments are driven by `[prepend set]` → `[comment]`.
Comment's `set` method takes a list (not just a symbol), so multi-word
status text like `"Started — 1200s, 6 performers"` displays correctly.
Don't downgrade this to `[sprintf set %s]` — that only captures the first
symbol and the rest of the status line will be lost.

### LAN URL detection

`server.js → lanIp()` prefers `en*` interfaces and falls back to anything
non-internal. On unusual setups (VPN, iOS Personal Hotspot via USB, a
secondary wifi adapter) the wrong IP may be picked. The URL emitted to the
patch is just a hint; performers can manually visit any IP that resolves
to this machine on the network.

# IMMER — Improvised Movement+Music Ensemble (web-driven)

Performers open a URL on their phones, enter their name, and drive their own role —
**I'm Dancing** or **I'm Playing Music** — from the page. The Max patch (`immer.maxpat`)
runs a local web server on your laptop and tracks who has danced with whom, played music
with whom, and who still needs a solo.

This is the inverse of the original Improvised Movement+Music Ensemble sequencer:
instead of pre-computing a permutation schedule and telling performers what to do, IMMER
lets performers self-organize while giving each one feedback on the configurations they
haven't yet tried.

## What each performer sees on their phone

**Above the buttons:** a countdown timer for the whole piece.

**The two buttons:** _I'm Playing Music_ / _I'm Dancing_. Tap to declare role. A small
*tap here to step out* link below lets them return to idle.

**Below the buttons, four lists:**
1. **Haven't played music with** — names they've never been in a music cohort with.
2. **Haven't danced with** — names they've never been in a dance cohort with.
3. **Still needs a solo** — performers who have not yet held a music or dance solo for
   the configured minimum duration. Each name carries a tag (`music`, `dance`, or both).
4. **Time playing music / Time dancing** — the running total this performer has spent
   in each role.

## Architecture

```
   ┌──────────────────────┐                 ┌────────────────────┐
   │   immer.maxpat       │ messages ↔ JS   │  server.js         │
   │   (Max 9)            │ ←─────────────→ │  node.script       │
   │   • cellblock        │   max-api       │  • http server     │
   │   • countdown        │                 │  • ws server       │
   │   • transport        │                 │  • state + pairing │
   └──────────────────────┘                 │  • solo detection  │
                                            └─────────┬──────────┘
                                                      │  http/ws
                                            ┌─────────▼──────────┐
                                            │  performers' phones│
                                            │  public/index.html │
                                            └────────────────────┘
```

Single `node.script` outlet, prefixed selectors routed in the patch:
`performer`, `roster`, `countdown`, `status`, `url`, `coverage`, `complete`, `cell`.

## First-time setup

1. **Install Max 9** (with the bundled Node for Max package).
2. From a terminal inside this folder, install the one server dependency:
   ```bash
   npm install
   ```
3. Open `immer.maxpat` in Max. The server auto-starts.

## Running a performance

1. Open the patch. The **Server URL** field shows `http://<your-lan-ip>:8080/`.
2. Performers join that URL from any phone/laptop on the same wifi and enter their name.
3. Set **Duration (min)** and **Solo hold (sec)** in the patch.
4. Hit **START**. Countdown begins; performers' role buttons activate.
5. **STOP** halts the countdown; **RESET** zeros everything for another run;
   **CLEAR** kicks all connected clients.

## Debugging

* **The `print SERVER` object** (top-right of the patch) streams every routed message to
  the Max console — every join, role change, snapshot tick, status update.
* **Right-click `node.script` → Debug** opens Chrome DevTools attached to the running
  Node process. Set breakpoints in `server.js`, inspect `performers`, eval anything.
* `node.script` has `@watch 1` — saving `server.js` reloads the server automatically.

## Files

| File                | Role                                                          |
|---------------------|---------------------------------------------------------------|
| `immer.maxpat`      | The Max patch — transport, displays, server host.             |
| `server.js`         | Loaded by `node.script`. HTTP + WebSocket server + state.     |
| `public/index.html` | Single-page web client served to performers.                  |
| `package.json`      | Declares the `ws` dependency.                                 |

## Notes

* `start`, `stop`, `reset`, `clear` are Max messages handled by `Max.addHandler` in
  `server.js`. Sending any of these to the `node.script` inlet from the patch fires them.
* If port 8080 is in use, change the **Port** number box; the server restarts on the new
  port and emits a fresh URL.
* Performers reconnecting under the same name keep their accumulated time and pairings,
  so a flaky wifi drop doesn't cost them coverage credit.

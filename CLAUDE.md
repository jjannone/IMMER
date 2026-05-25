# Working notes for Claude (and future contributors)

This file is the canonical home for project-specific lessons learned while
building IMMER. If you discover a non-obvious gotcha while working in this
repo — a Max attribute that silent-fails, a Node-for-Max quirk, a
WebSocket-on-LAN trap — **write it here**. Memory in `~/.claude/` is private
to one machine and invisible to anyone who clones the repo; knowledge
written here travels with the code.

---

## Patching lessons

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

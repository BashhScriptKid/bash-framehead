# `pubsub::topics`

**Signature:** `pubsub::topics()`

**Module:** [`pubsub`](../pubsub.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

List active topic names (one per line).


## Source

```bash
pubsub::topics() {
		_pubsub::ensure_root || return 1
		find "$PUBSUB_ROOT" -maxdepth 1 -type d ! -path "$PUBSUB_ROOT" -printf '%f\n' 2>/dev/null
}
```


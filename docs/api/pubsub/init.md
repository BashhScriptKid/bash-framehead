# `pubsub::init`

**Signature:** `pubsub::init()`

**Module:** [`pubsub`](../pubsub.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- PUBLIC API ---


## Source

```bash
pubsub::init() {
		PUBSUB_ROOT="${PUBSUB_ROOT:-$_PUBSUB_DEFAULT_ROOT}"
		mkdir -p "$PUBSUB_ROOT" 2>/dev/null || {
				echo "pubsub::init: failed to create PUBSUB_ROOT '$PUBSUB_ROOT'" >&2
				return 1
		}
}
```


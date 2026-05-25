# `pubsub::unsubscribe`

**Signature:** `pubsub::unsubscribe(<pipe>)`

**Module:** [`pubsub`](../pubsub.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Remove a subscription pipe. Validates the path is under PUBSUB_ROOT.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<pipe>` | string | Yes | |

## Source

```bash
pubsub::unsubscribe() {
		local pipe="$1"
		if [[ -z "$pipe" ]]; then
				echo "pubsub::unsubscribe: pipe path required" >&2
				return 1
		fi
		_pubsub::ensure_root || return 1
		if ! _pubsub::validate_pipe "$pipe"; then
				echo "pubsub::unsubscribe: path is not a valid subscription pipe: $pipe" >&2
				return 1
		fi
		rm -f "$pipe"
}
```


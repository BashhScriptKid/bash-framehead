# `pubsub::count`

**Signature:** `pubsub::count(<topic>)`

**Module:** [`pubsub`](../pubsub.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Count current subscribers on a topic. Prints an integer to stdout.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<topic>` | string | Yes | |

## Source

```bash
pubsub::count() {
		local topic="$1"
		if [[ -z "$topic" ]]; then
				echo "0"
				return 0
		fi
		_pubsub::ensure_root || return 1
		local topic_dir
		topic_dir=$(_pubsub::topic_dir "$topic")
		[[ -d "$topic_dir" ]] || { echo "0"; return 0; }
		find "$topic_dir" -type p 2>/dev/null | wc -l
}
```


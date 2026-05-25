# `pubsub::subscribe`

**Signature:** `pubsub::subscribe(pipe=$(pubsub::subscribe, <topic>))`

**Module:** [`pubsub`](../pubsub.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Create a named FIFO subscription on a topic. Prints the pipe path to stdout.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pipe=$(pubsub::subscribe` | string | Yes | |
| `<topic>)` | string | Yes | |

## Source

```bash
pubsub::subscribe() {
		local topic="$1"
		if [[ -z "$topic" ]]; then
				echo "pubsub::subscribe: topic required" >&2
				return 1
		fi
		_pubsub::ensure_root || return 1

		local topic_dir
		topic_dir=$(_pubsub::topic_dir "$topic")
		mkdir -p "$topic_dir" 2>/dev/null || {
				echo "pubsub::subscribe: failed to create topic dir '$topic_dir'" >&2
				return 1
		}

		local pipe_path max_attempts=10 attempt=0
		while (( attempt < max_attempts )); do
				pipe_path="$topic_dir/pipe.${RANDOM}${RANDOM}.$$"
				if mkfifo -m 600 "$pipe_path" 2>/dev/null; then
						echo "$pipe_path"
						return 0
				fi
				(( attempt++ ))
		done
		echo "pubsub::subscribe: failed to create FIFO after $max_attempts attempts" >&2
		return 1
}
```


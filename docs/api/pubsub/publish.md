# `pubsub::publish`

**Signature:** `pubsub::publish(echo, message, |, pubsub::publish, <topic>)`

**Module:** [`pubsub`](../pubsub.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Publish a message (from stdin) to all subscribers on a topic.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `echo` | string | Yes | |
| `message` | string | Yes | |
| `|` | string | Yes | |
| `pubsub::publish` | string | Yes | |
| `<topic>` | string | Yes | |

## Source

```bash
pubsub::publish() {
		local topic="$1"
		if [[ -z "$topic" ]]; then
				echo "pubsub::publish: topic required" >&2
				return 1
		fi
		_pubsub::ensure_root || return 1

		local topic_dir
		topic_dir=$(_pubsub::topic_dir "$topic")
		[[ -d "$topic_dir" ]] || return 0  # no topic dir = no subscribers, silent no-op

		local pipes=() pipe
		while IFS= read -r pipe; do
				pipes+=("$pipe")
		done < <(find "$topic_dir" -type p 2>/dev/null)

		if (( ${#pipes[@]} == 0 )); then
				return 0  # no subscribers
		fi

		local input
		input=$(cat)  # read entire stdin

		# Fan out with timeout — a blocked subscriber must not stall the publisher.
		# Write to each pipe in the background with a 2-second timeout.
		local pids=() pid
		for pipe in "${pipes[@]}"; do
				if command -v timeout &>/dev/null; then
						( timeout 2 bash -c 'echo "$1" > "$2"' _ "$input" "$pipe" 2>/dev/null || true ) &
				else
						( echo "$input" > "$pipe" 2>/dev/null || true ) &
				fi
				pids+=($!)
		done

		for pid in "${pids[@]}"; do
				wait "$pid" 2>/dev/null || true
		done
}
```


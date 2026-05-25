#!/usr/bin/env bash

# pubsub.sh -- bash::framehead named-pipe publish/subscribe
#
# In-process IPC via named pipes (FIFOs). Subscribers create pipes under a
# topic directory and read from them; publishers write to all pipes in a topic.
# Useful for background worker coordination, parallel job fan-out, and simple
# message passing between shell processes.
#
# CONFIGURATION:
#   PUBSUB_ROOT     Root directory for pipes. Default: /tmp/fsbshf-pubsub-$$
#
# EXAMPLE:
#   # Terminal 1 — subscriber
#   source bash-framehead.sh
#   pipe=$(pubsub::subscribe "mytopic")
#   while read -r msg; do echo "got: $msg"; done < "$pipe"
#
#   # Terminal 2 — publisher
#   source bash-framehead.sh
#   echo "hello world" | pubsub::publish "mytopic"
#
#   # Count subscribers
#   pubsub::count "mytopic"

# ==============================================================================
# CONSTANTS
# ==============================================================================

readonly _PUBSUB_DEFAULT_ROOT="/tmp/fsbshf-pubsub-$$"

# ==============================================================================
# INTERNAL
# ==============================================================================

# Ensure PUBSUB_ROOT is set and the directory exists.
# Called lazily by subscribe/publish so callers don't need to call pubsub::init.
_pubsub::ensure_root() {
		if [[ -z "${PUBSUB_ROOT:-}" ]]; then
				PUBSUB_ROOT="$_PUBSUB_DEFAULT_ROOT"
		fi
		[[ -d "$PUBSUB_ROOT" ]] || mkdir -p "$PUBSUB_ROOT" 2>/dev/null || {
				echo "pubsub: failed to create PUBSUB_ROOT '$PUBSUB_ROOT'" >&2
				return 1
		}
}

# Echo the directory path for a given topic (no side effects).
_pubsub::topic_dir() {
		local topic="$1"
		echo "$PUBSUB_ROOT/$topic"
}

# Validate that a pipe path is within PUBSUB_ROOT (safety check for unsubscribe).
_pubsub::validate_pipe() {
		local pipe="$1"
		[[ "$pipe" == "$PUBSUB_ROOT/"* ]] && [[ -p "$pipe" ]]
}

# ==============================================================================
# PUBLIC API
# ==============================================================================

# Set PUBSUB_ROOT default if not already configured by the caller.
# Usage: pubsub::init
pubsub::init() {
		PUBSUB_ROOT="${PUBSUB_ROOT:-$_PUBSUB_DEFAULT_ROOT}"
		mkdir -p "$PUBSUB_ROOT" 2>/dev/null || {
				echo "pubsub::init: failed to create PUBSUB_ROOT '$PUBSUB_ROOT'" >&2
				return 1
		}
}

# Create a named FIFO subscription on a topic. Prints the pipe path to stdout.
# The caller opens the pipe for reading (blocks until a publisher writes).
# Usage: pipe=$(pubsub::subscribe <topic>)
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

# Remove a subscription pipe. Validates the path is under PUBSUB_ROOT.
# Usage: pubsub::unsubscribe <pipe>
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

# Publish a message (from stdin) to all subscribers on a topic.
# Uses fan-out: each subscriber gets a copy. Non-blocking per subscriber
# so a dead subscriber never stalls the publisher.
# Usage: echo "message" | pubsub::publish <topic>
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

# List active topic names (one per line).
# Usage: pubsub::topics
pubsub::topics() {
		_pubsub::ensure_root || return 1
		find "$PUBSUB_ROOT" -maxdepth 1 -type d ! -path "$PUBSUB_ROOT" -printf '%f\n' 2>/dev/null
}

# Count current subscribers on a topic. Prints an integer to stdout.
# Usage: pubsub::count <topic>
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

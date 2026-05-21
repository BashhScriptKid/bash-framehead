# Example: Timed Retry Pattern

Uses `process` and `timedate` to retry a flaky command with backoff, measuring how long each attempt took and the total elapsed time.

## The simple case: `process::retry`

If you just need "try this N times with a fixed delay," `process::retry` is one call:

```bash
process::retry 5 2 curl -s https://api.example.com/status
```

Five attempts, two seconds between each. If the command succeeds (exit code 0), retrying stops immediately. If all five fail, the last failure's exit code is returned.

This covers most cases. The rest of this guide is for when you need more control.

## Per-attempt timing

Build a manual loop when you need to log per-attempt timing. Use the stopwatch for sub-millisecond resolution:

```bash
total_start=$(timedate::time::stopwatch::start)

for (( attempt=1; attempt <= max_attempts; attempt++ )); do
    att_start=$(timedate::time::stopwatch::start)

    if curl -s "https://api.example.com/status"; then
        att_elapsed=$(timedate::time::stopwatch::stop "$att_start")
        echo "  Succeeded on attempt $attempt in $(timedate::duration::format_ms "$att_elapsed")"
        break
    fi

    att_elapsed=$(timedate::time::stopwatch::stop "$att_start")
    echo "  Attempt $attempt failed ($(timedate::duration::format_ms "$att_elapsed"))"

    if (( attempt < max_attempts )); then
        sleep "$delay"
    else
        total_elapsed=$(timedate::time::stopwatch::stop "$total_start")
        echo "All $max_attempts attempts failed. Total time: $(timedate::duration::format_ms "$total_elapsed")" >&2
        exit 1
    fi
done
```

`stopwatch::start` returns a millisecond-precision token. `stopwatch::stop` takes that token and returns elapsed milliseconds. `duration::format_ms` turns raw milliseconds into something readable ("2s 340ms").

## Adding a per-attempt timeout

Use `process::timeout` to cap individual attempts so a hanging request doesn't stall the entire retry loop:

```bash
max_attempts=5
delay=2
timeout_per_attempt=10

for (( attempt=1; attempt <= max_attempts; attempt++ )); do
    echo "  Attempt $attempt (timeout: ${timeout_per_attempt}s)..."

    if process::timeout "$timeout_per_attempt" curl -s "$url"; then
        echo "  OK"
        break
    fi

    rc=$?
    if (( rc == 124 )); then
        echo "  Timed out after ${timeout_per_attempt}s"
    else
        echo "  Failed (exit code $rc)"
    fi

    if (( attempt == max_attempts )); then
        echo "All attempts exhausted." >&2
        exit 1
    fi

    sleep "$delay"
done
```

`process::timeout` returns exit code 124 on timeout (matching the GNU `timeout` convention) and the command's exit code otherwise.

## Logging with relative timestamps

For long-running retry loops, `timedate::duration::relative` adds context to log messages:

```bash
start_ts=$(timedate::timestamp::unix)

for (( attempt=1; attempt <= max_attempts; attempt++ )); do
    ago=$(timedate::duration::relative "$start_ts")
    echo "[$ago] Attempt $attempt..."

    if do_request; then
        echo "[$ago] Success"
        break
    fi

    sleep "$delay"
done
```

Output reads naturally: "[3 seconds ago] Attempt 1...", "[2 minutes ago] Attempt 5...".

## The complete retry-with-backoff function

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/bash_framehead.sh"

retry_with_backoff() {
    local max_attempts="$1"
    local base_delay="$2"
    local per_attempt_timeout="$3"
    shift 3

    local total_start
    total_start=$(timedate::time::stopwatch::start)

    local attempt delay
    for (( attempt=1; attempt <= max_attempts; attempt++ )); do
        local att_start
        att_start=$(timedate::time::stopwatch::start)

        if process::timeout "$per_attempt_timeout" "$@" 2>/dev/null; then
            local att_elapsed total_elapsed
            att_elapsed=$(timedate::time::stopwatch::stop "$att_start")
            total_elapsed=$(timedate::time::stopwatch::stop "$total_start")
            echo "Succeeded on attempt $attempt (attempt: $(timedate::duration::format_ms "$att_elapsed"), total: $(timedate::duration::format_ms "$total_elapsed"))"
            return 0
        fi

        local rc=$?
        if (( attempt == max_attempts )); then
            local total_elapsed
            total_elapsed=$(timedate::time::stopwatch::stop "$total_start")
            echo "All $max_attempts attempts failed (total: $(timedate::duration::format_ms "$total_elapsed"))" >&2
            return "$rc"
        fi

        # Exponential backoff: 2s, 4s, 8s, 16s...
        delay=$(( base_delay * (2 ** (attempt - 1)) ))
        echo "  Failed. Retrying in ${delay}s..." >&2
        sleep "$delay"
    done
}

# ---------- usage ----------
retry_with_backoff 5 2 10 curl -s https://api.example.com/status
```

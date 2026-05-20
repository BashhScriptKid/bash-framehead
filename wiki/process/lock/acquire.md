# `process::lock::acquire`

Acquire a lock — returns 1 if already locked

## Usage

```bash
process::lock::acquire lockname
```

## Source

```bash
process::lock::acquire() {
    local lockfile="/tmp/fsbshf_${1}.lock"
    if ( set -o noclobber; echo "$$" > "$lockfile" ) 2>/dev/null; then
        trap "process::lock::release '${1}'" EXIT
        return 0
    fi
    # Check if the locking process is still alive
    local locked_pid
    locked_pid=$(cat "$lockfile" 2>/dev/null)
    if [[ -n "$locked_pid" ]] && ! process::is_running "$locked_pid"; then
        rm -f "$lockfile"
        ( set -o noclobber; echo "$$" > "$lockfile" ) 2>/dev/null
        trap "process::lock::release '${1}'" EXIT
        return 0
    fi
    return 1
}
```

## Module

[`process`](../process.md)

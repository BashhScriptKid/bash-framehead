# `process::lock::is_locked`

Check if a lock is held

## Usage

```bash
process::lock::is_locked lockname
```

## Source

```bash
process::lock::is_locked() {
    local lockfile="/tmp/fsbshf_${1}.lock"
    [[ -f "$lockfile" ]] && process::is_running "$(cat "$lockfile" 2>/dev/null)"
}
```

## Module

[`process`](../process.md)

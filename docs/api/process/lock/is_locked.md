# `process::lock::is_locked`

**Signature:** `process::lock::is_locked(lockname)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a lock is held

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `lockname` | string | Yes | |

## Source

```bash
process::lock::is_locked() {
    local lockfile="/tmp/fsbshf_${1}.lock"
    [[ -f "$lockfile" ]] && process::is_running "$(cat "$lockfile" 2>/dev/null)"
}
```


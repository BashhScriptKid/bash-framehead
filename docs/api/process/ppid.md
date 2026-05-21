# `process::ppid`

**Signature:** `process::ppid(pid)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get parent PID of a process

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |

## Source

```bash
process::ppid() {
    local pid="${1:-$$}"
    awk '{print $4}' "/proc/$pid/stat" 2>/dev/null || \
        ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' '
}
```


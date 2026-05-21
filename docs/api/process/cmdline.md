# `process::cmdline`

**Signature:** `process::cmdline(pid)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get command line of a process

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |

## Source

```bash
process::cmdline() {
    local pid="${1:-$$}"
    if [[ -f "/proc/$pid/cmdline" ]]; then
        tr '\0' ' ' < "/proc/$pid/cmdline"
    else
        ps -o args= -p "$pid" 2>/dev/null
    fi
}
```


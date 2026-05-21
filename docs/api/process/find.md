# `process::find`

**Signature:** `process::find(pattern)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Find processes matching a pattern (name or cmdline)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pattern` | regex | Yes | |

## Source

```bash
process::find() {
    pgrep -a "$1" 2>/dev/null || ps -eo pid,args | grep "$1" | grep -v grep
}
```


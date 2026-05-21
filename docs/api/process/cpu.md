# `process::cpu`

**Signature:** `process::cpu(pid)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Get CPU usage percentage for a PID

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |

## Source

```bash
process::cpu() {
    ps -o pcpu= -p "$1" 2>/dev/null | tr -d ' '
}
```


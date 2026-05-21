# `process::signal`

**Signature:** `process::signal(pid, signal)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Send a signal to a process

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `pid` | integer | Yes | |
| `signal` | string | Yes | |

## Source

```bash
process::signal() {
    kill -"$2" "$1" 2>/dev/null
}
```


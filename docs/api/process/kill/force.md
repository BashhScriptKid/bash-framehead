# `process::kill::force`

**Signature:** `process::kill::force(arg1)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Force kill a process (SIGKILL)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::kill::force() {
    kill -KILL "$1" 2>/dev/null
}
```


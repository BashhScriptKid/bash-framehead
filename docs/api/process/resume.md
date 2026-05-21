# `process::resume`

**Signature:** `process::resume(arg1)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Resume a suspended process (SIGCONT)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::resume() {
    kill -CONT "$1" 2>/dev/null
}
```


# `process::job::status`

**Signature:** `process::job::status(arg1)`

**Module:** [`process`](../../process.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Get exit status of last background job

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::job::status() {
    wait "$1" 2>/dev/null
    echo $?
}
```


# `process::is_zombie`

**Signature:** `process::is_zombie(arg1)`

**Module:** [`process`](../process.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a process is a zombie

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
process::is_zombie() {
    [[ "$(process::state "$1")" == "Z" ]]
}
```


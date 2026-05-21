# `fs::path::is_absolute`

**Signature:** `fs::path::is_absolute(arg1)`

**Module:** [`fs`](../../fs.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a path is absolute

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::path::is_absolute() {
    [[ "$1" == /* ]]
}
```


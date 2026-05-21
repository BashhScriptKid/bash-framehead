# `fs::delete`

**Signature:** `fs::delete(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Delete file or directory

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::delete() {
    rm -rf "$1"
}
```


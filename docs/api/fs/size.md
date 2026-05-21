# `fs::size`

**Signature:** `fs::size(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

File size in bytes

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::size() {
    stat -c '%s' "$1" 2>/dev/null || wc -c < "$1" 2>/dev/null
}
```


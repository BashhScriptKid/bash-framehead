# `fs::inode`

**Signature:** `fs::inode(arg1)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Inode number

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
fs::inode() {
    stat -c '%i' "$1" 2>/dev/null
}
```


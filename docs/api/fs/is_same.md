# `fs::is_same`

**Signature:** `fs::is_same(arg1, arg2)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if two paths resolve to the same file (inode comparison)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
fs::is_same() {
		[[ "$(stat -c '%d:%i' "$1" 2>/dev/null)" == "$(stat -c '%d:%i' "$2" 2>/dev/null)" ]]
}
```


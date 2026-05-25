# `fs::prepend`

**Signature:** `fs::prepend(arg1, arg2)`

**Module:** [`fs`](../fs.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Prepend content to file

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
fs::prepend() {
		local tmp
		tmp=$(fs::temp::file)
		printf '%s\n' "$2" | cat - "$1" > "$tmp"
		mv "$tmp" "$1"
}
```


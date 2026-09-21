# `binary::buffer::concat`

**Signature:** `binary::buffer::concat(<dst>, <src>)`

**Module:** [`binary`](../../binary.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- CONCAT ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<dst>` | string | Yes | |
| `<src>` | string | Yes | |

## Source

```bash
binary::buffer::concat() {
	local -n _bbuf_dst="_binary_buffer_${1}"
	local -n _bbuf_src="_binary_buffer_${2}"
	_bbuf_dst+=("${_bbuf_src[@]}")
}
```


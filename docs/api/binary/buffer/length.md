# `binary::buffer::length`

**Signature:** `binary::buffer::length(<name>)`

**Module:** [`binary`](../../binary.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Echo current buffer length in bytes.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
binary::buffer::length() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	echo "${#_bbuf_ref[@]}"
}
```


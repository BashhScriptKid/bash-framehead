# `binary::buffer::shift::r`

**Signature:** `binary::buffer::shift::r(<name>, <count>)`

**Module:** [`binary`](../../../binary.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Remove <count> bytes from the end of the buffer.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<count>` | string | Yes | |

## Source

```bash
binary::buffer::shift::r() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local count=$2 len=${#_bbuf_ref[@]}
	(( count > len )) && count=$len
	_bbuf_ref=("${_bbuf_ref[@]:0:len-count}")
}
```


# `binary::buffer::shift::l`

**Signature:** `binary::buffer::shift::l(<name>, <count>)`

**Module:** [`binary`](../../../binary.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- SHIFT ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<count>` | string | Yes | |

## Source

```bash
binary::buffer::shift::l() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local count=$2
	_bbuf_ref=("${_bbuf_ref[@]:count}")
}
```


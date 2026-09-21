# `binary::buffer::read`

**Signature:** `binary::buffer::read(<name>)`

**Module:** [`binary`](../../binary.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Echo buffer contents without clearing (space-separated decimal values).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |

## Source

```bash
binary::buffer::read() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	printf '%s' "${_bbuf_ref[*]}"
}
```


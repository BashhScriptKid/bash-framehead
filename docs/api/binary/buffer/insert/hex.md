# `binary::buffer::insert::hex`

**Signature:** `binary::buffer::insert::hex(<name>, <hexstring>)`

**Module:** [`binary`](../../../binary.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Append bytes from a hex string.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<hexstring>` | string | Yes | |

## Source

```bash
binary::buffer::insert::hex() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local hex=$2 i pad=0 val
	(( ${#hex} % 2 != 0 )) && hex="0$hex"
	for ((i = 0; i < ${#hex}; i += 2)); do
		_bbuf_ref+=($((16#${hex:i:2})))
	done
}
```


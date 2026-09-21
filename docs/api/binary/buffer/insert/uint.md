# `binary::buffer::insert::uint`

**Signature:** `binary::buffer::insert::uint(<name>, <value>, <width>, [endian=le])`

**Module:** [`binary`](../../../binary.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Append an unsigned integer (fixed-width, little-endian by default).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<value>` | string | Yes | |
| `<width>` | string | Yes | |
| `endian=le` | string | No | |

## Source

```bash
binary::buffer::insert::uint() {
	local name=$1 value=$2 width=$3 endian=${4:-le}
	local -n _bbuf_ref="_binary_buffer_${name}"

	local i
	if [[ $endian == le ]]; then
		for ((i = 0; i < width; i++)); do
			_bbuf_ref+=($(( (value >> (8 * i)) & 0xFF )))
		done
	else
		local idx
		for ((idx = width - 1; idx >= 0; idx--)); do
			_bbuf_ref+=($(( (value >> (8 * idx)) & 0xFF )))
		done
	fi
}
```


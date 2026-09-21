# `binary::buffer::peek`

**Signature:** `binary::buffer::peek(<name>, <offset>, <length>, [mode=dec])`

**Module:** [`binary`](../../binary.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- PEEK ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<name>` | string | Yes | |
| `<offset>` | string | Yes | |
| `<length>` | string | Yes | |
| `mode=dec` | string | No | |

## Source

```bash
binary::buffer::peek() {
	local -n _bbuf_ref="_binary_buffer_${1}"
	local offset=$2 length=$3 mode=${4:-dec}
	local slice=("${_bbuf_ref[@]:offset:length}")

	case $mode in
		raw)
			_binary::_emit_raw slice
			;;
		hex)
			local _bpo_b
			for _bpo_b in "${slice[@]}"; do
				printf '%02x' "$_bpo_b"
			done
			;;
		dec|*)
			printf '%s' "${slice[*]}"
			;;
	esac
}
```


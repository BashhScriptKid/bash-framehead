# `binary::from_hex`

**Signature:** `binary::from_hex(<hex>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Emit raw bytes from a hex string (each pair of hex chars = 1 byte).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<hex>` | string | Yes | |

## Source

```bash
binary::from_hex() {
		local hex=$1
		(( ${#hex} % 2 != 0 )) && hex="0$hex"
		local i
		for ((i = 0; i < ${#hex}; i += 2)); do
				printf -v _fh_byte '\\x%s' "${hex:i:2}"
				printf '%b' "$_fh_byte"
		done
		unset _fh_byte
}
```


# `binary::from_int`

**Signature:** `binary::from_int(<n>)`

**Module:** [`binary`](../binary.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Emit raw bytes from a signed decimal integer (minimal-width two's complement LE).

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<n>` | string | Yes | |

## Source

```bash
binary::from_int() {
		local val=$1
		if (( val == 0 )); then
				printf '\x00'
				return
		fi

		local octets=() neg=0
		if (( val < 0 )); then
				neg=1
				(( val = -val ))
		fi

		# Encode absolute value as minimal unsigned bytes
		while (( val > 0 )); do
				octets+=($(( val & 0xFF )))
				(( val >>= 8 ))
		done

		if (( neg )); then
				# Two's complement: flip bits and add 1
				local carry=1 i
				for ((i = 0; i < ${#octets[@]}; i++)); do
						(( octets[i] = (~octets[i] & 0xFF) + carry ))
						(( carry = octets[i] >> 8 ? 1 : 0 ))
						(( octets[i] &= 0xFF ))
				done
				if (( carry )); then
						octets+=(1)
				fi
				# Ensure sign bit is set in the high byte
				if (( (octets[-1] & 0x80) == 0 )); then
						octets+=(0xFF)
				fi
		else
				# Positive: ensure sign bit is clear in the high byte
				if (( (octets[-1] & 0x80) != 0 )); then
						octets+=(0)
				fi
		fi

		local fmt
		printf -v fmt '\\x%02x' "${octets[@]}"
		printf '%b' "$fmt"
}
```


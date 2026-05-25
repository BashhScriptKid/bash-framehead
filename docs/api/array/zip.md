# `array::zip`

**Signature:** `array::zip(a1, a2, a3, b1, b2, b3)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Zip two arrays together — pairs elements by index

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `a1` | string | Yes | |
| `a2` | string | Yes | |
| `a3` | string | Yes | |
| `b1` | string | Yes | |
| `b2` | string | Yes | |
| `b3` | string | Yes | |

## Source

```bash
array::zip() {
		local -a a=($1) b=($2)
		local len=$(( ${#a[@]} < ${#b[@]} ? ${#a[@]} : ${#b[@]} ))
		local i
		for (( i=0; i<len; i++ )); do
				echo "${a[$i]} ${b[$i]}"
		done
}
```


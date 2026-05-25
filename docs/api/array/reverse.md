# `array::reverse`

**Signature:** `array::reverse(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Reverse order of elements

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::reverse() {
		local -a arr=("$@")
		local i
		for (( i=${#arr[@]}-1; i>=0; i-- )); do
				echo "${arr[$i]}"
		done
}
```


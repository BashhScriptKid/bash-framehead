# `array::zip::fast`

**Signature:** `array::zip::fast(result_arr, a1, a2, a3, b1, b2, b3)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `a1` | string | Yes | |
| `a2` | string | Yes | |
| `a3` | string | Yes | |
| `b1` | string | Yes | |
| `b2` | string | Yes | |
| `b3` | string | Yes | |

## Source

```bash
array::zip::fast() {
		local -n _array_zip_result="$1"
		local -a a=($2) b=($3)
		local len=$(( ${#a[@]} < ${#b[@]} ? ${#a[@]} : ${#b[@]} ))
		local i
		_array_zip_result=()
		for (( i=0; i<len; i++ )); do
				_array_zip_result+=("${a[$i]} ${b[$i]}")
		done
}
```


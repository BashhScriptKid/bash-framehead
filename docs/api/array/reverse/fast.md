# `array::reverse::fast`

**Signature:** `array::reverse::fast(result_arr, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::reverse::fast() {
		local -n _array_reverse_result="$1"
		shift
		local -a _arr=("$@")
		local i
		_array_reverse_result=()
		for (( i=${#_arr[@]}-1; i>=0; i-- )); do
				_array_reverse_result+=("${_arr[$i]}")
		done
}
```


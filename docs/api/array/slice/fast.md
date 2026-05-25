# `array::slice::fast`

**Signature:** `array::slice::fast(result_arr, start, length, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `start` | string | Yes | |
| `length` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::slice::fast() {
		local -n _array_slice_result="$1"
		local start="$2" len="$3"; shift 3
		local -a _arr=("$@")
		_array_slice_result=("${_arr[@]:$start:$len}")
}
```


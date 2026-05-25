# `array::shift::fast`

**Signature:** `array::shift::fast(result_arr, el1, el2, ...)`

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
array::shift::fast() {
		local -n _array_shift_result="$1"
		shift 2
		_array_shift_result=("$@")
}
```


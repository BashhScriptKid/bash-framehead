# `array::max::fast`

**Signature:** `array::max::fast(result_var, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::max::fast() {
		local -n _array_max_result="$1"
		shift
		local max="$1"
		for el in "$@"; do
				(( el > max )) && max="$el"
		done
		_array_max_result=$max
}
```


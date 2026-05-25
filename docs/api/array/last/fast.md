# `array::last::fast`

**Signature:** `array::last::fast(result_var, el1, el2, ...)`

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
array::last::fast() {
		local -n _array_last_result="$1"
		shift
		local -a _arr=("$@")
		_array_last_result="${_arr[-1]}"
}
```


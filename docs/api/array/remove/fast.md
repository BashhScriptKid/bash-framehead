# `array::remove::fast`

**Signature:** `array::remove::fast(result_arr, value, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `value` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::remove::fast() {
		local -n _array_remove_result="$1"
		local target="$2"; shift 2
		_array_remove_result=()
		for el in "$@"; do
				[[ "$el" != "$target" ]] && _array_remove_result+=("$el")
		done
}
```


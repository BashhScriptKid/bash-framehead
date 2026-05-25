# `array::remove_at::fast`

**Signature:** `array::remove_at::fast(result_arr, index, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `index` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::remove_at::fast() {
		local -n _array_remove_at_result="$1"
		local idx="$2"; shift 2
		local i=0
		_array_remove_at_result=()
		for el in "$@"; do
				[[ "$i" -ne "$idx" ]] && _array_remove_at_result+=("$el")
				(( i++ ))
		done
}
```


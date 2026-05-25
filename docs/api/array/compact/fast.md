# `array::compact::fast`

**Signature:** `array::compact::fast(result_arr, el1, el2, ...)`

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
array::compact::fast() {
		local -n _array_compact_result="$1"
		shift
		_array_compact_result=()
		for el in "$@"; do
				[[ -n "$el" ]] && _array_compact_result+=("$el")
		done
}
```


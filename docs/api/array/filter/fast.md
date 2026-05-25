# `array::filter::fast`

**Signature:** `array::filter::fast(result_arr, regex, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `regex` | regex | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::filter::fast() {
		local -n _array_filter_result="$1"
		local regex="$2"; shift 2
		_array_filter_result=()
		for el in "$@"; do
				[[ "$el" =~ $regex ]] && _array_filter_result+=("$el")
		done
}
```


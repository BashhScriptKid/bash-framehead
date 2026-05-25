# `array::index_of::fast`

**Signature:** `array::index_of::fast(result_var, needle, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `needle` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::index_of::fast() {
		local -n _array_index_of_result="$1"
		local needle="$2"; shift 2
		local i=0
		for el in "$@"; do
				[[ "$el" == "$needle" ]] && { _array_index_of_result=$i; return 0; }
				(( i++ ))
		done
		_array_index_of_result=-1
		return 1
}
```


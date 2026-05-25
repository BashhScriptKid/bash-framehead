# `array::count_of::fast`

**Signature:** `array::count_of::fast(result_var, needle, el1, el2, ...)`

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
array::count_of::fast() {
		local -n _array_count_of_result="$1"
		local needle="$2"; shift 2
		local count=0
		for el in "$@"; do
				[[ "$el" == "$needle" ]] && (( count++ ))
		done
		_array_count_of_result=$count
}
```


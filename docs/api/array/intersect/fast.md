# `array::intersect::fast`

**Signature:** `array::intersect::fast(result_arr, el1, el2, el3, el2, el3, el4)`

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
| `el3` | string | Yes | |
| `el2` | string | Yes | |
| `el3` | string | Yes | |
| `el4` | string | Yes | |

## Source

```bash
array::intersect::fast() {
		local -n _array_intersect_result="$1"
		local -a a=($2) b=($3)
		_array_intersect_result=()
		for el in "${a[@]}"; do
				for other in "${b[@]}"; do
						[[ "$el" == "$other" ]] && { _array_intersect_result+=("$el"); break; }
				done
		done
}
```


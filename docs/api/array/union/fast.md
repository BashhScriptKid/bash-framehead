# `array::union::fast`

**Signature:** `array::union::fast(result_arr, el1, el2, el2, el3)`

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
| `el2` | string | Yes | |
| `el3` | string | Yes | |

## Source

```bash
array::union::fast() {
		local -n _array_union_result="$1"
		local -a a=($2) b=($3)
		if runtime::is_minimum_bash 5; then
				_array_union_result=()
				local -A _seen=()
				for el in "${a[@]}" "${b[@]}"; do
						if [[ -z "${_seen[$el]+x}" ]]; then
								_seen["$el"]=1
								_array_union_result+=("$el")
						fi
				done
		else
				echo "array::union::fast: requires Bash 5+" >&2
				return 1
		fi
}
```


# `array::chunk::fast`

**Signature:** `array::chunk::fast(result_arr, size, el1, el2, ...)`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_arr` | variable | Yes | |
| `size` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::chunk::fast() {
		local -n _array_chunk_result="$1"
		local size="$2"; shift 2
		local i=0 chunk=""
		_array_chunk_result=()
		for el in "$@"; do
				if [[ -n "$chunk" ]]; then chunk+=" $el"
				else chunk="$el"; fi
				(( i++ ))
				if (( i % size == 0 )); then
						_array_chunk_result+=("$chunk")
						chunk=""
				fi
		done
		[[ -n "$chunk" ]] && _array_chunk_result+=("$chunk")
}
```


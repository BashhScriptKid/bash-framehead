# `array::chunk`

**Signature:** `array::chunk(size, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Chunk array into groups of n

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `size` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::chunk() {
		local size="$1" i=0; shift
		local chunk=""
		for el in "$@"; do
				if [[ -n "$chunk" ]]; then chunk+=" $el"
				else chunk="$el"; fi
				(( i++ ))
				if (( i % size == 0 )); then
						echo "$chunk"
						chunk=""
				fi
		done
		[[ -n "$chunk" ]] && echo "$chunk"
}
```


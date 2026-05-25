# `array::insert_at`

**Signature:** `array::insert_at(index, value, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Insert element at index

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `index` | string | Yes | |
| `value` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::insert_at() {
		local idx="$1" val="$2" i=0; shift 2
		for el in "$@"; do
				[[ "$i" -eq "$idx" ]] && echo "$val"
				echo "$el"
				(( i++ ))
		done
		# If index is beyond end, append
		[[ "$i" -le "$idx" ]] && echo "$val"
}
```


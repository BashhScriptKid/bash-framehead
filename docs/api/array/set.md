# `array::set`

**Signature:** `array::set(index, value, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Replace element at index with new value

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
array::set() {
		local idx="$1" val="$2" i=0; shift 2
		for el in "$@"; do
				[[ "$i" -eq "$idx" ]] && echo "$val" || echo "$el"
				(( i++ ))
		done
}
```


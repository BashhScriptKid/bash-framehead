# `array::min`

**Signature:** `array::min(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Minimum value (numeric)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::min() {
		local min="$1"; shift
		for el in "$@"; do
				(( el < min )) && min="$el"
		done
		echo "$min"
}
```


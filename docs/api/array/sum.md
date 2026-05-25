# `array::sum`

**Signature:** `array::sum(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Sum all numeric elements

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::sum() {
		local total=0
		for el in "$@"; do
				total=$(( total + el ))
		done
		echo "$total"
}
```


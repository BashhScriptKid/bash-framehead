# `array::get`

**Signature:** `array::get(index, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Return element at index

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `index` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::get() {
		local idx="$1"; shift
		local -a arr=("$@")
		echo "${arr[$idx]}"
}
```


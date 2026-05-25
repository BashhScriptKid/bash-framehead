# `array::push`

**Signature:** `array::push(new_el, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Append elements (print existing + new)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `new_el` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::push() {
		local new="$1"; shift
		printf '%s\n' "$@" "$new"
}
```


# `array::compact`

**Signature:** `array::compact(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Return only elements that are non-empty

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::compact() {
		for el in "$@"; do
				[[ -n "$el" ]] && echo "$el"
		done
}
```


# `array::contains`

**Signature:** `array::contains(needle, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if array contains a value

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `needle` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::contains() {
		local needle="$1"; shift
		local el
		for el in "$@"; do
				[[ "$el" == "$needle" ]] && return 0
		done
		return 1
}
```


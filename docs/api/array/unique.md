# `array::unique`

**Signature:** `array::unique(el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- BASH 5+ FEATURES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::unique() {
		local -A seen=()
		for el in "$@"; do
				if [[ -z "${seen[$el]+x}" ]]; then
						seen["$el"]=1
						echo "$el"
				fi
		done
}
```


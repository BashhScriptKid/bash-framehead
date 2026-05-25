# `array::index_of`

**Signature:** `array::index_of(needle, el1, el2, ...)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Return index of first match (-1 if not found)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `needle` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
array::index_of() {
		local needle="$1"; shift
		local i=0
		for el in "$@"; do
				[[ "$el" == "$needle" ]] && echo "$i" && return 0
				(( i++ ))
		done
		echo -1
		return 1
}
```


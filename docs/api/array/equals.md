# `array::equals`

**Signature:** `array::equals(el1, el2, el1, el2)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if two arrays are equal (same elements, same order)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `el1` | string | Yes | |
| `el2` | string | Yes | |

## Source

```bash
array::equals() {
		local -a a=($1) b=($2)
		[[ "${#a[@]}" -ne "${#b[@]}" ]] && return 1
		local i
		for (( i=0; i<${#a[@]}; i++ )); do
				[[ "${a[$i]}" != "${b[$i]}" ]] && return 1
		done
		return 0
}
```


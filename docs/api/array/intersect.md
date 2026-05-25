# `array::intersect`

**Signature:** `array::intersect(el1, el2, el3, el2, el3, el4)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- SET OPERATIONS ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2` | string | Yes | |
| `el3` | string | Yes | |
| `el2` | string | Yes | |
| `el3` | string | Yes | |
| `el4` | string | Yes | |

## Source

```bash
array::intersect() {
		local -a a=($1) b=($2)
		for el in "${a[@]}"; do
				for other in "${b[@]}"; do
						[[ "$el" == "$other" ]] && echo "$el" && break
				done
		done
}
```


# `array::diff`

**Signature:** `array::diff(el1, el2, el3, el2, el3, el4)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Difference — elements in first array not in second

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
array::diff() {
		local -a a=($1) b=($2)
		for el in "${a[@]}"; do
				local found=false
				for other in "${b[@]}"; do
						[[ "$el" == "$other" ]] && found=true && break
				done
				$found || echo "$el"
		done
}
```


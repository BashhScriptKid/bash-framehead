# `math::vec3::new::fast`

**Signature:** `math::vec3::new::fast(arg1)`

**Module:** [`math`](../../../math.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::vec3::new::fast() {
		[[ $# -lt 1 ]] && {
				echo "Usage: math::vec3::new::fast <var_name> [x] [y] [z]" >&2
				return 1
		}

		local -n vector=$1
		local x="${2:-0}" y="${3:-0}"

		[[ "$x" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || x=0
		[[ "$y" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || y=0

		vector="${x},${y}"
}
```


# `math::bc`

**Signature:** `math::bc(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::bc() {
		local expr="$1" scale="${2:-$MATH_SCALE}"
		if ! math::has_bc; then
				echo "math::bc: requires bc (GNU coreutils)" >&2
				return 1
		fi
		echo "scale=${scale}; ${expr}" | bc -l | sed 's/^\./0./; s/^-\./-0./'
}
```


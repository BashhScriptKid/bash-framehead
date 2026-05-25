# `math::rad_to_deg`

**Signature:** `math::rad_to_deg(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Convert radians to degrees

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::rad_to_deg() {
	local n
	if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
		math::bc "$n * 180 / $MATH_PI"
}
```


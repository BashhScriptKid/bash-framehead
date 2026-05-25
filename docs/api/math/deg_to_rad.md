# `math::deg_to_rad`

**Signature:** `math::deg_to_rad(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Convert degrees to radians

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::deg_to_rad() {
	local n
	if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
		math::bc "$n * $MATH_PI / 180"
}
```


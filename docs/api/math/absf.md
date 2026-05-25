# `math::absf`

**Signature:** `math::absf(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Absolute value (float) — Usage: math::absf n [scale]

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::absf() {
	local n scale
	if [[ $# -ge 1 ]]; then n="$1"; scale="${2:-$MATH_SCALE}"
	else n=$(cat); scale="${1:-$MATH_SCALE}"; fi
	math::bc "if ($n < 0) { -($n) } else { $n }" "$scale"
}
```


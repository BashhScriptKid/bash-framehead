# `math::lerp`

**Signature:** `math::lerp(a, b, t, [scale])`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Linear interpolation between a and b by factor t (0.0 - 1.0)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `a` | string | Yes | |
| `b` | string | Yes | |
| `t` | string | Yes | |
| `scale` | string | No | |

## Source

```bash
math::lerp() {
    local a="$1" b="$2" t="$3" scale="${4:-$MATH_SCALE}"
    math::bc "$a + ($b - $a) * $(math::clampf "$t" 0 1)" "$scale"
}
```


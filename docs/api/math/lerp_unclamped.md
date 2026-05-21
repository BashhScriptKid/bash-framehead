# `math::lerp_unclamped`

**Signature:** `math::lerp_unclamped(arg1, arg2, arg3)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
math::lerp_unclamped() {
    local a="$1" b="$2" t="$3" scale="${4:-$MATH_SCALE}"
    math::bc "$a + $t * ($b - $a)" "$scale"
}
```


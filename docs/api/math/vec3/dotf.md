# `math::vec3::dotf`

**Signature:** `math::vec3::dotf(scale x1,y1,z1 x2,y2,z2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Dot product of two vec3 vectors with floating point precision

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x1` | string | Yes | |
| `y1` | string | Yes | |
| `z1 x2` | string | Yes | |
| `y2` | string | Yes | |
| `z2` | string | Yes | |

## Source

```bash
math::vec3::dotf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    math::bc "$x1 * $x2 + $y1 * $y2 + $z1 * $z2" "$scale"
}
```


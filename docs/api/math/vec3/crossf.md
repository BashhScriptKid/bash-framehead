# `math::vec3::crossf`

**Signature:** `math::vec3::crossf(scale x1,y1,z1 x2,y2,z2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Cross product of two vec3 vectors with floating point precision

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
math::vec3::crossf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    echo "$(math::bc "$y1*$z2 - $z1*$y2" "$scale"),$(math::bc "$z1*$x2 - $x1*$z2" "$scale"),$(math::bc "$x1*$y2 - $y1*$x2" "$scale")"
}
```


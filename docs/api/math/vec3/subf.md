# `math::vec3::subf`

**Signature:** `math::vec3::subf(scale x1,y1,z1 x2,y2,z2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Subtract vec3 b from vec3 a with floating point precision

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
math::vec3::subf() {
    local scale=$1 x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$2" "$3"
    echo "$(math::bc "$x1 - $x2" "$scale"),$(math::bc "$y1 - $y2" "$scale"),$(math::bc "$z1 - $z2" "$scale")"
}
```


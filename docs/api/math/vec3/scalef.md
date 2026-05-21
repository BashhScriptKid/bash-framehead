# `math::vec3::scalef`

**Signature:** `math::vec3::scalef(scale x,y,z scalar)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Scale a vec3 by a scalar with floating point precision

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x` | string | Yes | |
| `y` | string | Yes | |
| `z scalar` | string | Yes | |

## Source

```bash
math::vec3::scalef() {
    local scale=$1 x y z
    _math::vec3::unpack3 x y z "$2"
    echo "$(math::bc "$x * $3" "$scale"),$(math::bc "$y * $3" "$scale"),$(math::bc "$z * $3" "$scale")"
}
```


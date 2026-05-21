# `math::vec3::scale`

**Signature:** `math::vec3::scale(x,y,z scalar)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Scale a vec3 by a scalar

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x` | string | Yes | |
| `y` | string | Yes | |
| `z scalar` | string | Yes | |

## Source

```bash
math::vec3::scale() {
    local x y z
    _math::vec3::unpack3 x y z "$1"
    echo "$(( x * $2 )),$(( y * $2 )),$(( z * $2 ))"
}
```


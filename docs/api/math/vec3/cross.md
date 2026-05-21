# `math::vec3::cross`

**Signature:** `math::vec3::cross(x1,y1,z1 x2,y2,z2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Cross product of two vec3 vectors

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x1` | string | Yes | |
| `y1` | string | Yes | |
| `z1 x2` | string | Yes | |
| `y2` | string | Yes | |
| `z2` | string | Yes | |

## Source

```bash
math::vec3::cross() {
    local x1 y1 z1 x2 y2 z2
    _math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
    echo "$(( y1*z2 - z1*y2 )),$(( z1*x2 - x1*z2 )),$(( x1*y2 - y1*x2 ))"
}
```


# `math::vec2::scale`

**Signature:** `math::vec2::scale(x,y scalar)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Scale a vec2 by a scalar

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x` | string | Yes | |
| `y scalar` | string | Yes | |

## Source

```bash
math::vec2::scale() {
    local x y
    _math::vec2::unpack2 x y "$1"
    echo "$(( x * $2 )),$(( y * $2 ))"
}
```


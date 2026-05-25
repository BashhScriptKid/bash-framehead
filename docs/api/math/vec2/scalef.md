# `math::vec2::scalef`

**Signature:** `math::vec2::scalef(scale x,y scalar)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Scale a vec2 by a scalar with floating point precision

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x` | string | Yes | |
| `y scalar` | string | Yes | |

## Source

```bash
math::vec2::scalef() {
		local scale=$1 x y
		_math::vec2::unpack2 x y "$2"
		echo "$(math::bc "$x * $3" "$scale"),$(math::bc "$y * $3" "$scale")"
}
```


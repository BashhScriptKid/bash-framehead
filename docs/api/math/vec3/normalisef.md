# `math::vec3::normalisef`

**Signature:** `math::vec3::normalisef(scale x,y,z)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Normalise a vec3 with explicit scale

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x` | string | Yes | |
| `y` | string | Yes | |
| `z` | string | Yes | |

## Source

```bash
math::vec3::normalisef() {
		local scale=$1 x y z mag
		_math::vec3::unpack3 x y z "$2"
		mag=$(math::bc "sqrt($x*$x + $y*$y + $z*$z)" "$scale")
		echo "$(math::bc "$x / $mag" "$scale"),$(math::bc "$y / $mag" "$scale"),$(math::bc "$z / $mag" "$scale")"
}
```


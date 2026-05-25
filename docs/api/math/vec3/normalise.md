# `math::vec3::normalise`

**Signature:** `math::vec3::normalise(x,y,z)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Normalise a vec3 to unit length — requires bc

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x` | string | Yes | |
| `y` | string | Yes | |
| `z` | string | Yes | |

## Source

```bash
math::vec3::normalise() {
		local x y z mag
		_math::vec3::unpack3 x y z "$1"
		mag=$(math::bc "sqrt($x*$x + $y*$y + $z*$z)")
		echo "$(math::bc "$x / $mag"),$(math::bc "$y / $mag"),$(math::bc "$z / $mag")"
}
```


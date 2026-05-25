# `math::vec2::normalise`

**Signature:** `math::vec2::normalise(x,y)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Normalise a vec2 to unit length — requires bc

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x` | string | Yes | |
| `y` | string | Yes | |

## Source

```bash
math::vec2::normalise() {
		local x y mag
		_math::vec2::unpack2 x y "$1"
		mag=$(math::bc "sqrt($x * $x + $y * $y)")
		echo "$(math::bc "$x / $mag"),$(math::bc "$y / $mag")"
}
```


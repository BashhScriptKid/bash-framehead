# `math::vec2::normalisef`

**Signature:** `math::vec2::normalisef(scale x,y)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Normalise a vec2 with explicit scale

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x` | string | Yes | |
| `y` | string | Yes | |

## Source

```bash
math::vec2::normalisef() {
		local scale=$1 x y mag
		_math::vec2::unpack2 x y "$2"
		mag=$(math::bc "sqrt($x * $x + $y * $y)" "$scale")
		echo "$(math::bc "$x / $mag" "$scale"),$(math::bc "$y / $mag" "$scale")"
}
```


# `math::vec2::addf`

**Signature:** `math::vec2::addf(scale x1,y1 x2,y2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Add two vec2 vectors with floating point precision

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x1` | string | Yes | |
| `y1 x2` | string | Yes | |
| `y2` | string | Yes | |

## Source

```bash
math::vec2::addf() {
		local scale=$1 x1 y1 x2 y2
		_math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
		echo "$(math::bc "$x1 + $x2" "$scale"),$(math::bc "$y1 + $y2" "$scale")"
}
```


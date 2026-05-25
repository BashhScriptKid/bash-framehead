# `math::vec3::magnitudef`

**Signature:** `math::vec3::magnitudef(scale x,y,z)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Magnitude with explicit scale

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x` | string | Yes | |
| `y` | string | Yes | |
| `z` | string | Yes | |

## Source

```bash
math::vec3::magnitudef() {
		local scale=$1 x y z
		_math::vec3::unpack3 x y z "$2"
		math::bc "sqrt($x*$x + $y*$y + $z*$z)" "$scale"
}
```


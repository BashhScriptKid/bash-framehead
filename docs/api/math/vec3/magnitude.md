# `math::vec3::magnitude`

**Signature:** `math::vec3::magnitude(x,y,z)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Magnitude (length) of a vec3 — requires bc

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x` | string | Yes | |
| `y` | string | Yes | |
| `z` | string | Yes | |

## Source

```bash
math::vec3::magnitude() {
		local x y z
		_math::vec3::unpack3 x y z "$1"
		math::bc "sqrt($x*$x + $y*$y + $z*$z)"
}
```


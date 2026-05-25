# `math::vec2::magnitude`

**Signature:** `math::vec2::magnitude(x,y)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Magnitude (length) of a vec2 — requires bc

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x` | string | Yes | |
| `y` | string | Yes | |

## Source

```bash
math::vec2::magnitude() {
		local x y
		_math::vec2::unpack2 x y "$1"
		math::bc "sqrt($x * $x + $y * $y)"
}
```


# `math::vec2::magnitudef`

**Signature:** `math::vec2::magnitudef(scale x,y)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Magnitude with explicit scale

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x` | string | Yes | |
| `y` | string | Yes | |

## Source

```bash
math::vec2::magnitudef() {
    local scale=$1 x y
    _math::vec2::unpack2 x y "$2"
    math::bc "sqrt($x * $x + $y * $y)" "$scale"
}
```


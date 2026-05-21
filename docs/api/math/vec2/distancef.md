# `math::vec2::distancef`

**Signature:** `math::vec2::distancef(scale x1,y1 x2,y2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Distance between two vec2 points with explicit scale

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale x1` | string | Yes | |
| `y1 x2` | string | Yes | |
| `y2` | string | Yes | |

## Source

```bash
math::vec2::distancef() {
    local scale=$1 x1 y1 x2 y2
    _math::vec2::unpack4 x1 y1 x2 y2 "$2" "$3"
    math::bc "sqrt(($x1-$x2)*($x1-$x2) + ($y1-$y2)*($y1-$y2))" "$scale"
}
```


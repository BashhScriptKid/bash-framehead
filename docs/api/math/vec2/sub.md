# `math::vec2::sub`

**Signature:** `math::vec2::sub(x1,y1 x2,y2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Subtract vec2 b from vec2 a

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x1` | string | Yes | |
| `y1 x2` | string | Yes | |
| `y2` | string | Yes | |

## Source

```bash
math::vec2::sub() {
		local x1 y1 x2 y2
		_math::vec2::unpack4 x1 y1 x2 y2 "$1" "$2"
		echo "$(( x1 - x2 )),$(( y1 - y2 ))"
}
```


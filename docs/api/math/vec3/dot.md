# `math::vec3::dot`

**Signature:** `math::vec3::dot(x1,y1,z1 x2,y2,z2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Dot product of two vec3 vectors

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `x1` | string | Yes | |
| `y1` | string | Yes | |
| `z1 x2` | string | Yes | |
| `y2` | string | Yes | |
| `z2` | string | Yes | |

## Source

```bash
math::vec3::dot() {
		local x1 y1 z1 x2 y2 z2
		_math::vec3::unpack6 x1 y1 z1 x2 y2 z2 "$1" "$2"
		echo "$(( x1 * x2 + y1 * y2 + z1 * z2 ))"
}
```


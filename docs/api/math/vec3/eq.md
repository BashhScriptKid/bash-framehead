# `math::vec3::eq`

**Signature:** `math::vec3::eq(x1,y1,z1 x2,y2,z2)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if two vec3 vectors are equal

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
math::vec3::eq() {
    [[ "$1" == "$2" ]]
}
```


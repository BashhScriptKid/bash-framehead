# `math::matrix::is_square`

**Signature:** `math::matrix::is_square(RxC)`

**Module:** [`math`](../../math.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a matrix is square (rows == cols)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `RxC` | string | Yes | |

## Source

```bash
math::matrix::is_square() {
    local rows cols
    _math::matrix::dim "$1" rows cols
    (( rows == cols ))
}
```


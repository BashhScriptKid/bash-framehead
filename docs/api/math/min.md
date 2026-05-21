# `math::min`

**Signature:** `math::min(arg1, arg2)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Minimum of two values (integer)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
math::min() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::min: float input — use math::minf" >&2; return 1; }
    echo $(( $1 < $2 ? $1 : $2 ))
}
```


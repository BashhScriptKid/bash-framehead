# `math::div`

**Signature:** `math::div(dividend, divisor)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Integer division (truncated toward zero)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `dividend` | string | Yes | |
| `divisor` | string | Yes | |

## Source

```bash
math::div() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::div: float input — use math::bc for float division" >&2; return 1; }
    echo $(( $1 / $2 ))
}
```


# `math::mod`

**Signature:** `math::mod(arg1, arg2)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Modulo

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
math::mod() {
    _math::is_float "$1" || _math::is_float "$2" && { echo "math::mod: float input — use math::bc for float modulo" >&2; return 1; }
    echo $(( $1 % $2 ))
}
```


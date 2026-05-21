# `pfloat::ieee754::abs`

**Signature:** `pfloat::ieee754::abs(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Absolute value

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::abs() {
  echo $(( $1 & ~9223372036854775808 ))
}
```


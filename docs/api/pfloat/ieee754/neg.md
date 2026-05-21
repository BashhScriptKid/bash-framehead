# `pfloat::ieee754::neg`

**Signature:** `pfloat::ieee754::neg(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Negation

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::neg() {
  echo $(( $1 ^ 9223372036854775808 ))
}
```


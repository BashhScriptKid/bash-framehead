# `pfloat::ieee754::sub`

**Signature:** `pfloat::ieee754::sub(arg1, arg2)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Subtraction (uses addition with negated operand)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::ieee754::sub() {
  local a="$1" b="$2"
  # Flip sign bit of b and add
  local neg_b=$((b ^ 9223372036854775808))
  pfloat::ieee754::add "$a" "$neg_b"
}
```


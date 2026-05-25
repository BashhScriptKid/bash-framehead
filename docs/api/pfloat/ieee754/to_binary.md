# `pfloat::ieee754::to_binary`

**Signature:** `pfloat::ieee754::to_binary(<bits>)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Decompose 64-bit pattern into sign, exponent, mantissa

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<bits>` | string | Yes | |

## Source

```bash
pfloat::ieee754::to_binary() {
	local bits="$1"
	local sign; sign=$(_ieee754::get_sign "$bits")
	local exp;   exp=$(_ieee754::get_exp "$bits")
	local mant;  mant=$(_ieee754::get_mant "$bits")
	printf '%d\n%d\n%d' "$sign" "$exp" "$mant"
}
```


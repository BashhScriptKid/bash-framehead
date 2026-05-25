# `pfloat::ieee754::dump`

**Signature:** `pfloat::ieee754::dump(<bits>)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

IEEE 754: Pretty-print bit representation

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<bits>` | string | Yes | |

## Source

```bash
pfloat::ieee754::dump() {
	local bits="$1"
	local sign; sign=$(_ieee754::get_sign "$bits")
	local exp;   exp=$(_ieee754::get_exp "$bits")
	local mant;  mant=$(_ieee754::get_mant "$bits")
	printf 'sign=%d exp=%d mantissa=0x%013x' "$sign" "$exp" "$mant"
}
```


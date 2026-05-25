# `pfloat::ieee754::from_binary`

**Signature:** `pfloat::ieee754::from_binary(<sign>, <exp>, <mantissa>)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Build 64-bit pattern from sign, exponent, mantissa strings

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<sign>` | string | Yes | |
| `<exp>` | string | Yes | |
| `<mantissa>` | string | Yes | |

## Source

```bash
pfloat::ieee754::from_binary() {
	local sign="$1" exp="$2" mant="$3"
	local s_val=$((2#$sign))
	local e_val=$((2#$exp))
	local m_val=$((2#$mant))
	_ieee754::pack "$s_val" "$e_val" "$m_val"
}
```


# `pfloat::ieee754::is_positive`

**Signature:** `pfloat::ieee754::is_positive(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Check if value is positive (non-zero, non-negative)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::ieee754::is_positive() {
	local bits="$1"
	local sign=$(_ieee754::get_sign "$bits")
	((sign == 0)) && ! _ieee754::is_zero "$bits"
}
```


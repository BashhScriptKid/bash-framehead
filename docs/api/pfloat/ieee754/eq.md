# `pfloat::ieee754::eq`

**Signature:** `pfloat::ieee754::eq(arg1, arg2)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Comparison (returns 0 for true, 1 for false)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::ieee754::eq() {
	local a="$1" b="$2"
	# Handle signed zero
	local abs_a=$((a & ~9223372036854775808))
	local abs_b=$((b & ~9223372036854775808))
	((abs_a == abs_b))
}
```


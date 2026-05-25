# `pfloat::ieee754::ge`

**Signature:** `pfloat::ieee754::ge(arg1, arg2)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

IEEE 754: Greater-than-or-equal comparison

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::ieee754::ge() {
	local a="$1" b="$2"
	! pfloat::ieee754::lt "$a" "$b"
}
```


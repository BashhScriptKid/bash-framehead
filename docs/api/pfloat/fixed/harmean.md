# `pfloat::fixed::harmean`

**Signature:** `pfloat::fixed::harmean(arg1, arg2)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::fixed::harmean() {
	local a="$1" b="$2"
	local sum prod
	sum=$(pfloat::fixed::add "$a" "$b")
	prod=$(pfloat::fixed::mul "$a" "$b")
	pfloat::fixed::div $(pfloat::fixed::mul "2" "$prod") "$sum"
}
```


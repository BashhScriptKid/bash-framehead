# `pfloat::fixed::sqr`

**Signature:** `pfloat::fixed::sqr(arg1)`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
pfloat::fixed::sqr() {
	pfloat::fixed::mul "$1" "$1"
}
```


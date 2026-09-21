# `pfloat::fixed::sqr::fast`

**Signature:** `pfloat::fixed::sqr::fast(arg1, arg2)`

**Module:** [`pfloat`](../../../pfloat.md) — [Guide](../../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
pfloat::fixed::sqr::fast() {
	pfloat::fixed::mul::fast "$1" "$1" "$2"
}
```


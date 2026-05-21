# `pfloat::fixed::geomean`

**Signature:** `pfloat::fixed::geomean(arg1, arg2)`

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
pfloat::fixed::geomean() {
  local a="$1" b="$2"
  local prod
  prod=$(pfloat::fixed::mul "$a" "$b")
  pfloat::fixed::sqrt "$prod"
}
```


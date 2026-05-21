# `pfloat::fixed::percent_of`

**Signature:** `pfloat::fixed::percent_of(arg1, arg2)`

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
pfloat::fixed::percent_of() {
  local pct="$1" total="$2"
  pfloat::fixed::mul "$total" $(pfloat::fixed::div "$pct" "100")
}
```


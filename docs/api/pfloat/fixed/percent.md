# `pfloat::fixed::percent`

**Signature:** `pfloat::fixed::percent(arg1, arg2)`

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
pfloat::fixed::percent() {
  local part="$1" total="$2"
  local ratio
  ratio=$(pfloat::fixed::div "$part" "$total")
  pfloat::fixed::mul "$ratio" "100"
}
```


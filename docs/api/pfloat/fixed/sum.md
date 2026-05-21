# `pfloat::fixed::sum`

**Signature:** `pfloat::fixed::sum()`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
pfloat::fixed::sum() {
  local total="0"
  for n in "$@"; do
    total=$(pfloat::fixed::add "$total" "$n")
  done
  echo "$total"
}
```


# `pfloat::fixed::avg`

**Signature:** `pfloat::fixed::avg()`

**Module:** [`pfloat`](../../pfloat.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
pfloat::fixed::avg() {
  local count=$#
  ((count == 0)) && {
    echo "pfloat::fixed::avg: no arguments" >&2
    return 1
  }

  local total
  total=$(pfloat::fixed::sum "$@")
  pfloat::fixed::div "$total" "$count"
}
```


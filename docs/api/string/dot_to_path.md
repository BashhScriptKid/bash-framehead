# `string::dot_to_path`

**Signature:** `string::dot_to_path()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

dot.case → path/case


## Source

```bash
string::dot_to_path() {
  local input; _string::read_input input "$@"
  echo "${input//.//}"
}
```


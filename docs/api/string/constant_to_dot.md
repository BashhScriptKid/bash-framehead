# `string::constant_to_dot`

**Signature:** `string::constant_to_dot()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

CONSTANT_CASE → dot.case


## Source

```bash
string::constant_to_dot() {
  local input; _string::read_input input "$@"
  local s="${input//_/.}"
  echo "${s,,}"
}
```


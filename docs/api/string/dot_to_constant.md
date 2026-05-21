# `string::dot_to_constant`

**Signature:** `string::dot_to_constant()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

dot.case → CONSTANT_CASE


## Source

```bash
string::dot_to_constant() {
  local input; _string::read_input input "$@"
  local s="${input//./_}"
  echo "${s^^}"
}
```


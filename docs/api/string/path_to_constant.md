# `string::path_to_constant`

**Signature:** `string::path_to_constant()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

path/case → CONSTANT_CASE


## Source

```bash
string::path_to_constant() {
  local input; _string::read_input input "$@"
  local s="${input//\//_}"
  echo "${s^^}"
}
```


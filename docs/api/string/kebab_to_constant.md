# `string::kebab_to_constant`

**Signature:** `string::kebab_to_constant()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

kebab-case → CONSTANT_CASE


## Source

```bash
string::kebab_to_constant() {
  local input; _string::read_input input "$@"
  local s="${input//-/_}"
  echo "${s^^}"
}
```


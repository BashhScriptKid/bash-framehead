# `string::kebab_to_dot`

**Signature:** `string::kebab_to_dot()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

kebab-case → dot.case


## Source

```bash
string::kebab_to_dot() {
  local input; _string::read_input input "$@"
  echo "${input//-/.}"
}
```


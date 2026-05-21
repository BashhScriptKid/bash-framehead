# `string::plain_to_kebab`

**Signature:** `string::plain_to_kebab()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

plain → kebab-case


## Source

```bash
string::plain_to_kebab() {
  local input; _string::read_input input "$@"
  local s="${input// /-}"
  echo "${s,,}"
}
```


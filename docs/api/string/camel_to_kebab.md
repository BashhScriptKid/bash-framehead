# `string::camel_to_kebab`

**Signature:** `string::camel_to_kebab()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

camelCase → kebab-case


## Source

```bash
string::camel_to_kebab() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  echo "${words// /-}"
}
```


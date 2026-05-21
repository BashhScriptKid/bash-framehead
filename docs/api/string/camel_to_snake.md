# `string::camel_to_snake`

**Signature:** `string::camel_to_snake()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

camelCase → snake_case


## Source

```bash
string::camel_to_snake() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  echo "${words// /_}"
}
```


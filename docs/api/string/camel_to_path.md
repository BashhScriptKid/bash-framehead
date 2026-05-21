# `string::camel_to_path`

**Signature:** `string::camel_to_path()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

camelCase → path/case


## Source

```bash
string::camel_to_path() {
  local input; _string::read_input input "$@"
  local words
  words=$(_string::to_words "$input")
  echo "${words// //}"
}
```


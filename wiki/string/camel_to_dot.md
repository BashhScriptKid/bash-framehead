# `string::camel_to_dot`

camelCase → dot.case

## Source

```bash
string::camel_to_dot() {
  local words
  words=$(_string::to_words "$1")
  echo "${words// /.}"
}
```

## Module

[`string`](../string.md)

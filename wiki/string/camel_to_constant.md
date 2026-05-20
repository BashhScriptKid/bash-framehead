# `string::camel_to_constant`

camelCase → CONSTANT_CASE

## Source

```bash
string::camel_to_constant() {
  local words
  words=$(_string::to_words "$1")
  local s="${words// /_}"
  echo "${s^^}"
}
```

## Module

[`string`](../string.md)

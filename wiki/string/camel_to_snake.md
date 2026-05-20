# `string::camel_to_snake`

camelCase → snake_case

## Source

```bash
string::camel_to_snake() {
  local words
  words=$(_string::to_words "$1")
  echo "${words// /_}"
}
```

## Module

[`string`](../string.md)

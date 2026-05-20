# `string::camel_to_path`

camelCase → path/case

## Source

```bash
string::camel_to_path() {
  local words
  words=$(_string::to_words "$1")
  echo "${words// //}"
}
```

## Module

[`string`](../string.md)

# `string::path_to_camel`

path/case → camelCase

## Source

```bash
string::path_to_camel() {
  string::plain_to_camel "${1//\// }"
}
```

## Module

[`string`](../string.md)

# `string::snake_to_camel`

snake_case → camelCase

## Source

```bash
string::snake_to_camel() {
  string::plain_to_camel "${1//_/ }"
}
```

## Module

[`string`](../string.md)

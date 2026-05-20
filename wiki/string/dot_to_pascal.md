# `string::dot_to_pascal`

dot.case → PascalCase

## Source

```bash
string::dot_to_pascal() {
  string::plain_to_pascal "${1//./ }"
}
```

## Module

[`string`](../string.md)

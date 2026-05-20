# `string::dot_to_kebab`

dot.case → kebab-case

## Source

```bash
string::dot_to_kebab() {
  echo "${1//./-}"
}
```

## Module

[`string`](../string.md)

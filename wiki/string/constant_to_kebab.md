# `string::constant_to_kebab`

CONSTANT_CASE → kebab-case

## Source

```bash
string::constant_to_kebab() {
  local s="${1//_/-}"
  echo "${s,,}"
}
```

## Module

[`string`](../string.md)

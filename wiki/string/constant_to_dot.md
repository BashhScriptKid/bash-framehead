# `string::constant_to_dot`

CONSTANT_CASE → dot.case

## Source

```bash
string::constant_to_dot() {
  local s="${1//_/.}"
  echo "${s,,}"
}
```

## Module

[`string`](../string.md)

# `string::dot_to_constant`

dot.case → CONSTANT_CASE

## Source

```bash
string::dot_to_constant() {
  local s="${1//./_}"
  echo "${s^^}"
}
```

## Module

[`string`](../string.md)

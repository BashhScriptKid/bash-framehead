# `string::plain_to_constant`

plain → CONSTANT_CASE

## Source

```bash
string::plain_to_constant() {
  local s="${1// /_}"
  echo "${s^^}"
}
```

## Module

[`string`](../string.md)

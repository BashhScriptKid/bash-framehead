# `string::path_to_constant`

path/case → CONSTANT_CASE

## Source

```bash
string::path_to_constant() {
  local s="${1//\//_}"
  echo "${s^^}"
}
```

## Module

[`string`](../string.md)

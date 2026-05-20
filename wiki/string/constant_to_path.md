# `string::constant_to_path`

CONSTANT_CASE → path/case

## Source

```bash
string::constant_to_path() {
  local s="${1//_//}"
  echo "${s,,}"
}
```

## Module

[`string`](../string.md)

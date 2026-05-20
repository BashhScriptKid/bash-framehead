# `string::plain_to_kebab`

plain → kebab-case

## Source

```bash
string::plain_to_kebab() {
  local s="${1// /-}"
  echo "${s,,}"
}
```

## Module

[`string`](../string.md)

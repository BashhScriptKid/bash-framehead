# `string::plain_to_dot`

plain → dot.case

## Source

```bash
string::plain_to_dot() {
  local s="${1// /.}"
  echo "${s,,}"
}
```

## Module

[`string`](../string.md)

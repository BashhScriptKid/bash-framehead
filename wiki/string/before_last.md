# `string::before_last`

Return everything before the last occurrence of delimiter

## Source

```bash
string::before_last() {
  echo "${1%"$2"*}"
}
```

## Module

[`string`](../string.md)

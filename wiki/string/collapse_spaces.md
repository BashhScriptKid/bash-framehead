# `string::collapse_spaces`

Collapse multiple consecutive spaces into one

## Source

```bash
string::collapse_spaces() {
  echo "$1" | tr -s ' '
}
```

## Module

[`string`](../string.md)

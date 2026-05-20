# `string::strip_spaces`

Remove all whitespace

## Source

```bash
string::strip_spaces() {
  echo "${1//[[:space:]]/}"
}
```

## Module

[`string`](../string.md)

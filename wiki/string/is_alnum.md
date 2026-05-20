# `string::is_alnum`

Check if string is alphanumeric only

## Source

```bash
string::is_alnum() {
  [[ "$1" =~ ^[a-zA-Z0-9]+$ ]]
}
```

## Module

[`string`](../string.md)

# `string::is_integer`

Check if string is a valid integer

## Source

```bash
string::is_integer() {
  [[ "$1" =~ ^-?[0-9]+$ ]]
}
```

## Module

[`string`](../string.md)

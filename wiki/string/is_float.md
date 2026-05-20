# `string::is_float`

Check if string is a valid float

## Source

```bash
string::is_float() {
  [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?$ ]]
}
```

## Module

[`string`](../string.md)

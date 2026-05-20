# `string::is_hex`

_No description available._

## Source

```bash
string::is_hex() {
  [[ "$1" =~ ^(0[xX])?[0-9A-Fa-f]+$ ]]
}
```

## Module

[`string`](../string.md)

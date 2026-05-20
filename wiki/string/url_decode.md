# `string::url_decode`

_No description available._

## Source

```bash
string::url_decode() {
    local s="${1//+/ }"  # replace + with space first
    printf '%b\n' "${s//%/\\x}"
}
```

## Module

[`string`](../string.md)

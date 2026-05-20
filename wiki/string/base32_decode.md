# `string::base32_decode`

_No description available._

## Source

```bash
string::base32_decode() {
    if runtime::has_command base32; then
        echo -n "$1" | base32 --decode
    elif runtime::has_command gbase32; then
        echo -n "$1" | gbase32 --decode
    else
        echo "string::base32_decode: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}
```

## Module

[`string`](../string.md)

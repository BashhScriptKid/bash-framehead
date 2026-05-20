# `string::base32_encode`

_No description available._

## Source

```bash
string::base32_encode() {
    if runtime::has_command base32; then
        echo -n "$1" | base32
    elif runtime::has_command gbase32; then  # homebrew coreutils on macOS
        echo -n "$1" | gbase32
    else
        echo "string::base32_encode: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}
```

## Module

[`string`](../string.md)

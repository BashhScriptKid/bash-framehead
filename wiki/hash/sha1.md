# `hash::sha1`

SHA1 hash of a string

## Source

```bash
hash::sha1() {
    if runtime::has_command sha1sum; then
        _hash::pipe "$1" sha1sum | awk '{print $1}'
    elif runtime::has_command shasum; then
        _hash::pipe "$1" shasum -a 1 | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$1" openssl dgst -sha1 | awk '{print $NF}'
    else
        echo "hash::sha1: requires sha1sum, shasum, or openssl" >&2
        return 1
    fi
}
```

## Module

[`hash`](../hash.md)

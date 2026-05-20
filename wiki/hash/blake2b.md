# `hash::blake2b`

BLAKE2b hash of a string

## Source

```bash
hash::blake2b() {
    if runtime::has_command b2sum; then
        _hash::pipe "$1" b2sum | awk '{print $1}'
    elif runtime::has_command openssl; then
        _hash::pipe "$1" openssl dgst -blake2b512 2>/dev/null | awk '{print $NF}'
    else
        echo "hash::blake2b: requires b2sum or openssl" >&2
        return 1
    fi
}
```

## Module

[`hash`](../hash.md)

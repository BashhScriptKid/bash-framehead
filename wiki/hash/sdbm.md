# `hash::sdbm`

SDBM hash — used in the SDBM database library
Often outperforms DJB2 for database keys

## Source

```bash
hash::sdbm() {
    local s="$1" hash=0 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( (char + (hash << 6) + (hash << 16) - hash) & 0xFFFFFFFF ))
    done
    echo "$hash"
}
```

## Module

[`hash`](../hash.md)

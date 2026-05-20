# `hash::fnv1a32`

FNV-1a 32-bit — Fowler-Noll-Vo, excellent avalanche, widely used

**Period:** 2^32

## Source

```bash
hash::fnv1a32() {
    local s="$1" hash=2166136261 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( (hash ^ char) * 16777619 & 0xFFFFFFFF ))
    done
    echo "$hash"
}
```

## Module

[`hash`](../hash.md)

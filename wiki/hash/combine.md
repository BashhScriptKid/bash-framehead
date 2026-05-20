# `hash::combine`

Hash multiple values into one — useful for cache keys from multiple inputs

## Usage

```bash
hash::combine val1 val2 val3 ...
```

## Source

```bash
hash::combine() {
    local combined
    combined=$(printf '%s\0' "$@" | hash::sha256 /dev/stdin 2>/dev/null) || \
    combined=$(printf '%s:' "$@" | hash::sha256)
    echo "$combined"
}
```

## Module

[`hash`](../hash.md)

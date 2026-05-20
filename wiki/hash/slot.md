# `hash::slot`

Consistent hashing — map a value to a bucket (0 to n-1)
Useful for load balancing, sharding, cache partitioning

## Usage

```bash
hash::slot n_buckets value
```

## Source

```bash
hash::slot() {
    local n="$1" value="$2"
    local h
    h=$(hash::fnv1a32 "$value")
    echo $(( h % n ))
}
```

## Module

[`hash`](../hash.md)

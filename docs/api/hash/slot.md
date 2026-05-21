# `hash::slot`

**Signature:** `hash::slot(n_buckets, value)`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Consistent hashing — map a value to a bucket (0 to n-1)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n_buckets` | string | Yes | |
| `value` | string | Yes | |

## Source

```bash
hash::slot() {
    local n="$1" value="$2"
    local h
    h=$(hash::fnv1a32 "$value")
    echo $(( h % n ))
}
```


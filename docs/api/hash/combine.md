# `hash::combine`

**Signature:** `hash::combine(val1, val2, val3, ...)`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Hash multiple values into one — useful for cache keys from multiple inputs

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `val1` | string | Yes | |
| `val2` | string | Yes | |
| `val3` | string | Yes | |
| `...` | any | — | |

## Source

```bash
hash::combine() {
    local combined
    combined=$(printf '%s\0' "$@" | hash::sha256 /dev/stdin 2>/dev/null) || \
    combined=$(printf '%s:' "$@" | hash::sha256)
    echo "$combined"
}
```


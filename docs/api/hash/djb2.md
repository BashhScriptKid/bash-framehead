# `hash::djb2`

**Signature:** `hash::djb2(string)`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

DJB2 — Daniel J. Bernstein's hash, classic and fast

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `string` | string | Yes | |

## Source

```bash
hash::djb2() {
  local input; _hash::read_input input "$@"
    local s="$input" hash=5381 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( ((hash << 5) + hash + char) & 0xFFFFFFFF ))
    done
    echo "$hash"
}
```


# `hash::sdbm`

**Signature:** `hash::sdbm()`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

SDBM hash — used in the SDBM database library


## Source

```bash
hash::sdbm() {
  local input; _hash::read_input input "$@"
    local s="$input" hash=0 i char
    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        hash=$(( (char + (hash << 6) + (hash << 16) - hash) & 0xFFFFFFFF ))
    done
    echo "$hash"
}
```


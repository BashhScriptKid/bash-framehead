# `hash::fnv1a64`

FNV-1a 64-bit — larger state, better for longer strings

> [!NOTE]
> bash uses signed 64-bit integers; result may be negative for large hashes

## Source

```bash
hash::fnv1a64() {
    local s="$1"
    local hash_lo=2166136261 hash_hi=0
    local fnv_prime_lo=16777619 i char

    for (( i=0; i<${#s}; i++ )); do
        char=$(printf '%d' "'${s:$i:1}")
        # XOR low 32 bits with byte
        hash_lo=$(( (hash_lo ^ char) & 0xFFFFFFFF ))
        # Multiply: (hi:lo) * prime — simplified since prime fits in 32 bits
        local new_lo=$(( (hash_lo * fnv_prime_lo) & 0xFFFFFFFF ))
        local carry=$(( hash_lo * fnv_prime_lo >> 32 ))
        hash_hi=$(( (hash_hi * fnv_prime_lo + carry) & 0xFFFFFFFF ))
        hash_lo=$new_lo
    done

    printf '%08x%08x\n' "$hash_hi" "$hash_lo"
}
```

## Module

[`hash`](../hash.md)

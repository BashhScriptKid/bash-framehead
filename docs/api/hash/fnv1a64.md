# `hash::fnv1a64`

**Signature:** `hash::fnv1a64()`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

FNV-1a 64-bit — larger state, better for longer strings


## Source

```bash
hash::fnv1a64() {
	local input; _hash::read_input input "$@"
		local _str="$input"
		local hash_lo=2166136261 hash_hi=0
		local fnv_prime_lo=16777619 i char

		for (( i=0; i<${#s}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
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


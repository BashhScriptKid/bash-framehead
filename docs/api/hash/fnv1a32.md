# `hash::fnv1a32`

**Signature:** `hash::fnv1a32()`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

FNV-1a 32-bit — Fowler-Noll-Vo, excellent avalanche, widely used


## Source

```bash
hash::fnv1a32() {
	local input; _hash::read_input input "$@"
		local _str="$input" hash=2166136261 i char
		for (( i=0; i<${#s}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				hash=$(( (hash ^ char) * 16777619 & 0xFFFFFFFF ))
		done
		echo "$hash"
}
```


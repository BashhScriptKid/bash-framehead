# `hash::djb2a`

**Signature:** `hash::djb2a()`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

DJB2a (xor variant) — slightly better distribution than djb2


## Source

```bash
hash::djb2a() {
	local input; _hash::read_input input "$@"
		local _str="$input" hash=5381 i char
		for (( i=0; i<${#s}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				hash=$(( ((hash << 5) + hash ^ char) & 0xFFFFFFFF ))
		done
		echo "$hash"
}
```


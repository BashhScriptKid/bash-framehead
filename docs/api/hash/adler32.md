# `hash::adler32`

**Signature:** `hash::adler32()`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Adler-32 — fast checksum used in zlib/PNG


## Source

```bash
hash::adler32() {
	local input; _hash::read_input input "$@"
		local _str="$input"
		local a=1 b=0 i char MOD=65521

		for (( i=0; i<${#s}; i++ )); do
				char=$(printf '%d' "'${_str:$i:1}")
				a=$(( (a + char) % MOD ))
				b=$(( (b + a) % MOD ))
		done

		echo $(( (b << 16) | a ))
}
```


# `hash::blake2b`

**Signature:** `hash::blake2b(arg1)`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

BLAKE2b hash of a string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
hash::blake2b() {
	local input; _hash::read_input input "$@"
		if runtime::has_command b2sum; then
				_hash::pipe "$input" b2sum | awk '{print $1}'
		elif runtime::has_command openssl; then
				_hash::pipe "$input" openssl dgst -blake2b512 2>/dev/null | awk '{print $NF}'
		else
				echo "hash::blake2b: requires b2sum or openssl" >&2
				return 1
		fi
}
```


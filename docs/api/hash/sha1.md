# `hash::sha1`

**Signature:** `hash::sha1(arg1)`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

SHA1 hash of a string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
hash::sha1() {
	local input; _hash::read_input input "$@"
		if runtime::has_command sha1sum; then
				_hash::pipe "$input" sha1sum | awk '{print $1}'
		elif runtime::has_command shasum; then
				_hash::pipe "$input" shasum -a 1 | awk '{print $1}'
		elif runtime::has_command openssl; then
				_hash::pipe "$input" openssl dgst -sha1 | awk '{print $NF}'
		else
				echo "hash::sha1: requires sha1sum, shasum, or openssl" >&2
				return 1
		fi
}
```


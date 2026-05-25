# `hash::md5`

**Signature:** `hash::md5(string)`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- CRYPTOGRAPHIC ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `string` | string | Yes | |

## Source

```bash
hash::md5() {
	local input; _hash::read_input input "$@"
		if runtime::has_command md5sum; then
				_hash::pipe "$input" md5sum | awk '{print $1}'
		elif runtime::has_command md5; then
				_hash::pipe "$input" md5 -q 2>/dev/null || \
				_hash::pipe "$input" md5 | awk '{print $NF}'
		else
				echo "hash::md5: requires md5sum or md5" >&2
				return 1
		fi
}
```


# `hash::equal`

**Signature:** `hash::equal(string1, string2, [algorithm])`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if two strings have the same hash (constant-time safe via hash comparison)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `string1` | string | Yes | |
| `string2` | string | Yes | |
| `algorithm` | string | No | |

## Source

```bash
hash::equal() {
		local _hash_a _hash_b algo="${3:-sha256}"
		_hash_a=$(hash::"$algo" "$1" 2>/dev/null) || return 1
		_hash_b=$(hash::"$algo" "$2" 2>/dev/null) || return 1
		[[ "$_hash_a" == "$_hash_b" ]]
}
```


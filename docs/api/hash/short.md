# `hash::short`

**Signature:** `hash::short(string, [length])`

**Module:** [`hash`](../hash.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Generate a short hash — first n chars of sha256

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `string` | string | Yes | |
| `length` | string | No | |

## Source

```bash
hash::short() {
	local input; _hash::read_input input "$@"
		local _str="$input" len="${2:-8}"
		local full
		full=$(hash::sha256 "$_str") || return 1
		echo "${full:0:$len}"
}
```


# `string::random`

**Signature:** `string::random([length])`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- GENERATION ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `length` | string | No | |

## Source

```bash
string::random() {
	local input; _string::read_input input "$@"
	local len="${input:-16}"
	cat /dev/urandom 2>/dev/null |
		tr -dc 'a-zA-Z0-9' |
		head -c "$len" ||
		echo "string::random: /dev/urandom unavailable" >&2
}
```


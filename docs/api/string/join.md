# `string::join`

**Signature:** `string::join(delimiter, arg1, arg2, ...)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Join an array of arguments with a delimiter

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `delimiter` | string | Yes | |
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
string::join() {
	local delim="$1"
	shift
	local result=""
	local first=true
	for part in "$@"; do
		if $first; then
			result="$part"
			first=false
		else
			result+="${delim}${part}"
		fi
	done
	echo "$result"
}
```


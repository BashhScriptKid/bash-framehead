# `string::split`

**Signature:** `string::split(str, delimiter)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- SPLITTING / JOINING ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `delimiter` | string | Yes | |

## Source

```bash
string::split() {
	local input delim
	if [[ $# -ge 2 ]]; then
		input="$1"; delim="$2"
	else
		input=$(cat); delim="$1"
	fi
	local IFS="$delim"
	set -- $input
	printf '%s\n' "$@"
}
```


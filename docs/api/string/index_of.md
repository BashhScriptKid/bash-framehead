# `string::index_of`

**Signature:** `string::index_of(haystack, needle)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Index of first occurrence of substring (-1 if not found)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `haystack` | string | Yes | |
| `needle` | string | Yes | |

## Source

```bash
string::index_of() {
	local input needle
	if [[ $# -ge 2 ]]; then
		input="$1"; needle="$2"
	else
		input=$(cat); needle="$1"
	fi
	local before="${input%%"$needle"*}"
	if [[ "$before" == "$input" ]]; then
		echo -1
	else
		echo "${#before}"
	fi
}
```


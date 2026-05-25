# `string::repeat`

**Signature:** `string::repeat(str, n)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Repeat a string n times

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `n` | integer | Yes | |

## Source

```bash
string::repeat() {
	local input n
	if [[ $# -ge 2 ]]; then
		input="$1"; n="$2"
	else
		input=$(cat); n="$1"
	fi
	local result=""
	for ((i = 0; i < n; i++)); do result+="$input"; done
	echo "$result"
}
```


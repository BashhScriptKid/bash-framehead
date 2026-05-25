# `string::after`

**Signature:** `string::after(str, delimiter)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Return everything after the first occurrence of delimiter

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `delimiter` | string | Yes | |

## Source

```bash
string::after() {
	local input
	if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
	echo "${input#*"$1"}"
}
```


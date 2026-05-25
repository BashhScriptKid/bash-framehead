# `string::replace_all`

**Signature:** `string::replace_all(str, search, replace)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Replace all occurrences of search with replace

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `search` | string | Yes | |
| `replace` | string | Yes | |

## Source

```bash
string::replace_all() {
	local input
	if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
	echo "${input//"$1"/"$2"}"
}
```


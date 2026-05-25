# `string::remove`

**Signature:** `string::remove(str, substring)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Remove all occurrences of a substring

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `substring` | string | Yes | |

## Source

```bash
string::remove() {
	local input
	if [[ $# -ge 2 ]]; then input="$1"; shift; else input=$(cat); fi
	echo "${input//"$1"/}"
}
```


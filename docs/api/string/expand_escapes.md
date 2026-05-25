# `string::expand_escapes`

**Signature:** `string::expand_escapes(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Expand escape sequences: \n → newline, \t → tab, \\ → \, etc.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::expand_escapes() {
	local input; _string::read_input input "$@"
	printf '%s\n' "${input@E}"
}
```


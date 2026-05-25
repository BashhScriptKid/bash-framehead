# `string::assoc_kv`

**Signature:** `string::assoc_kv(varname)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Print keys and values of an associative array as alternating words.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | Yes | |

## Source

```bash
string::assoc_kv() {
	_runtime::min_bash 5.2 || return 1
	local -n _string_assoc_kv_ref="$1" 2>/dev/null || return 1
	echo "${_string_assoc_kv_ref[@]@k}"
}
```


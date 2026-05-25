# `string::assoc_dump`

**Signature:** `string::assoc_dump(varname)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Serialize an associative array to reconstructable key=value form.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `varname` | variable | Yes | |

## Source

```bash
string::assoc_dump() {
	_runtime::min_bash 5.1 || return 1
	local -n _string_assoc_dump_ref="$1" 2>/dev/null || return 1
	echo "${_string_assoc_dump_ref[@]@K}"
}
```


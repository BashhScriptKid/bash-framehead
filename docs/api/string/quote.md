# `string::quote`

**Signature:** `string::quote(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

PARAMETER TRANSFORMATIONS

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::quote() {
	local input; _string::read_input input "$@"
	if (( _RUNTIME_FEATURES & 1 )); then
		printf '%s\n' "${input@Q}"
	else
		printf '%q\n' "$input"
	fi
}
```


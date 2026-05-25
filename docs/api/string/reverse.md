# `string::reverse`

**Signature:** `string::reverse(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Reverse a string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::reverse() {
	local input; _string::read_input input "$@"
	if runtime::has_command rev; then
		echo "$input" | rev
	else
		echo "$input" | awk '{for(i=length;i>0;i--) printf substr($0,i,1); print ""}'
	fi
}
```


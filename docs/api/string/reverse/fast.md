# `string::reverse::fast`

**Signature:** `string::reverse::fast(result_var, str)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref (requires rev or awk)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |

## Source

```bash
string::reverse::fast() {
	local -n _string_reverse_result="$1"
	if runtime::has_command rev; then
		_string_reverse_result=$(echo "$2" | rev)
	else
		_string_reverse_result=$(echo "$2" | awk '{for(i=length;i>0;i--) printf substr($0,i,1); print ""}')
	fi
}
```


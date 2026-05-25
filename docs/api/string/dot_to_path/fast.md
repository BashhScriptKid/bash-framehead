# `string::dot_to_path::fast`

**Signature:** `string::dot_to_path::fast(result_var, arg1)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |

## Source

```bash
string::dot_to_path::fast() {
	local -n _string_dot_to_path_result="$1"
	_string_dot_to_path_result="${2//.//}"
}
```


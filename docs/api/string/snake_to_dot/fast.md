# `string::snake_to_dot::fast`

**Signature:** `string::snake_to_dot::fast(result_var, arg1)`

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
string::snake_to_dot::fast() {
	local -n _string_snake_to_dot_result="$1"
	_string_snake_to_dot_result="${2//_/.}"
}
```


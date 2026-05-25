# `string::constant_to_snake::fast`

**Signature:** `string::constant_to_snake::fast(result_var, arg1)`

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
string::constant_to_snake::fast() {
	local -n _string_constant_to_snake_result="$1"
	_string_constant_to_snake_result="${2,,}"
}
```


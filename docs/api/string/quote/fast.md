# `string::quote::fast`

**Signature:** `string::quote::fast(result_var, str)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |

## Source

```bash
string::quote::fast() {
	local -n _string_quote_result="$1"
	printf -v _string_quote_result '%s' "${2@Q}"
}
```


# `string::expand_escapes::fast`

**Signature:** `string::expand_escapes::fast(result_var, str)`

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
string::expand_escapes::fast() {
	local -n _string_expand_escapes_result="$1"
	printf -v _string_expand_escapes_result '%s' "${2@E}"
}
```


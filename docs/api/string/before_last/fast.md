# `string::before_last::fast`

**Signature:** `string::before_last::fast(result_var, str, delimiter)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |
| `delimiter` | string | Yes | |

## Source

```bash
string::before_last::fast() {
	local -n _string_before_last_result="$1"
	_string_before_last_result="${2%"$3"*}"
}
```


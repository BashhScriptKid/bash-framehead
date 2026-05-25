# `string::collapse_spaces::fast`

**Signature:** `string::collapse_spaces::fast(result_var, str)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref (requires tr)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |

## Source

```bash
string::collapse_spaces::fast() {
	local -n _string_collapse_spaces_result="$1"
	_string_collapse_spaces_result=$(echo "$2" | tr -s ' ')
}
```


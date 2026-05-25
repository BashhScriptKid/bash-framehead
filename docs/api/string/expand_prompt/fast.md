# `string::expand_prompt::fast`

**Signature:** `string::expand_prompt::fast(result_var, str)`

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
string::expand_prompt::fast() {
	local -n _string_expand_prompt_result="$1"
	printf -v _string_expand_prompt_result '%s' "${2@P}"
}
```


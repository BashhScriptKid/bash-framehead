# `string::url_decode::fast`

**Signature:** `string::url_decode::fast(result_var, str)`

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
string::url_decode::fast() {
		local -n _string_url_decode_result="$1"
		local _str="${2//+/ }"
		_string_url_decode_result=$(printf '%b\n' "${_str//%/\\x}")
}
```


# `string::split::fast`

**Signature:** `string::split::fast(result_var, delimiter, string)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast split — writes directly into the named array via nameref.

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `delimiter` | string | Yes | |
| `string` | string | Yes | |

## Source

```bash
string::split::fast() {
	local -n _split_out="$1"
	local _split_delim="$2" _split_str="$3"
	local IFS="$_split_delim"
	set -- $_split_str
	_split_out=("$@")
}
```


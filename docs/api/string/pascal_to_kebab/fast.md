# `string::pascal_to_kebab::fast`

**Signature:** `string::pascal_to_kebab::fast(result_var, arg1, arg2)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
string::pascal_to_kebab::fast() {
	local -n _string_pascal_to_kebab_result="$1"
	local _str="$2"
	_str="$(echo "$_str" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
	_str="${_str//_/ }"
	_str="${_str//-/ }"
	_str="${_str//./ }"
	_str="${_str//\// }"
	_str="${s,,}"
	_string_pascal_to_kebab_result="${_str// /-}"
}
```


# `string::camel_to_constant`

**Signature:** `string::camel_to_constant()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

camelCase → CONSTANT_CASE


## Source

```bash
string::camel_to_constant() {
	local input; _string::read_input input "$@"
	local words
	words=$(_string::to_words "$input")
	local _str="${words// /_}"
	echo "${s^^}"
}
```


# `string::camel_to_dot`

**Signature:** `string::camel_to_dot()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

camelCase → dot.case


## Source

```bash
string::camel_to_dot() {
	local input; _string::read_input input "$@"
	local words
	words=$(_string::to_words "$input")
	echo "${words// /.}"
}
```


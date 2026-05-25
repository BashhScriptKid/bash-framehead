# `string::plain_to_constant`

**Signature:** `string::plain_to_constant()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

plain → CONSTANT_CASE


## Source

```bash
string::plain_to_constant() {
	local input; _string::read_input input "$@"
	local _str="${input// /_}"
	echo "${s^^}"
}
```


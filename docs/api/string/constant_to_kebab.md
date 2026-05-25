# `string::constant_to_kebab`

**Signature:** `string::constant_to_kebab()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

CONSTANT_CASE → kebab-case


## Source

```bash
string::constant_to_kebab() {
	local input; _string::read_input input "$@"
	local _str="${input//_/-}"
	echo "${s,,}"
}
```


# `string::constant_to_path`

**Signature:** `string::constant_to_path()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

CONSTANT_CASE → path/case


## Source

```bash
string::constant_to_path() {
	local input; _string::read_input input "$@"
	local _str="${input//_//}"
	echo "${s,,}"
}
```


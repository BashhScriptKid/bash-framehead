# `string::plain_to_path`

**Signature:** `string::plain_to_path()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

plain → path/case


## Source

```bash
string::plain_to_path() {
	local input; _string::read_input input "$@"
	local _str="${input// //}"
	echo "${s,,}"
}
```


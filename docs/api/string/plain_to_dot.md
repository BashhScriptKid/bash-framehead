# `string::plain_to_dot`

**Signature:** `string::plain_to_dot()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

plain → dot.case


## Source

```bash
string::plain_to_dot() {
	local input; _string::read_input input "$@"
	local _str="${input// /.}"
	echo "${s,,}"
}
```


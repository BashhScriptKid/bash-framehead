# `string::snake_to_dot`

**Signature:** `string::snake_to_dot()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

snake_case → dot.case


## Source

```bash
string::snake_to_dot() {
	local input; _string::read_input input "$@"
	echo "${input//_/.}"
}
```


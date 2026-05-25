# `string::constant_to_snake`

**Signature:** `string::constant_to_snake()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

CONSTANT_CASE → snake_case


## Source

```bash
string::constant_to_snake() {
	local input; _string::read_input input "$@"
	echo "${input,,}"
}
```


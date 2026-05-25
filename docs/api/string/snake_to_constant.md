# `string::snake_to_constant`

**Signature:** `string::snake_to_constant()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

snake_case → CONSTANT_CASE


## Source

```bash
string::snake_to_constant() {
	local input; _string::read_input input "$@"
	echo "${input^^}"
}
```


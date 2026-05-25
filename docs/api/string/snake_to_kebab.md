# `string::snake_to_kebab`

**Signature:** `string::snake_to_kebab()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

snake_case → kebab-case


## Source

```bash
string::snake_to_kebab() {
	local input; _string::read_input input "$@"
	echo "${input//_/-}"
}
```


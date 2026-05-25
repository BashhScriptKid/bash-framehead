# `string::kebab_to_snake`

**Signature:** `string::kebab_to_snake()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

kebab-case → snake_case


## Source

```bash
string::kebab_to_snake() {
	local input; _string::read_input input "$@"
	echo "${input//-/_}"
}
```


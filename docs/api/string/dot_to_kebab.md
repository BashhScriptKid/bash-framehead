# `string::dot_to_kebab`

**Signature:** `string::dot_to_kebab()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

dot.case → kebab-case


## Source

```bash
string::dot_to_kebab() {
	local input; _string::read_input input "$@"
	echo "${input//./-}"
}
```


# `string::kebab_to_path`

**Signature:** `string::kebab_to_path()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

kebab-case → path/case


## Source

```bash
string::kebab_to_path() {
	local input; _string::read_input input "$@"
	echo "${input//-//}"
}
```


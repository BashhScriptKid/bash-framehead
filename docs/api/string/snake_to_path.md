# `string::snake_to_path`

**Signature:** `string::snake_to_path()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

snake_case → path/case


## Source

```bash
string::snake_to_path() {
	local input; _string::read_input input "$@"
	echo "${input//_//}"
}
```


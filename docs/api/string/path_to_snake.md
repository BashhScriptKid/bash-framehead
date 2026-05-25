# `string::path_to_snake`

**Signature:** `string::path_to_snake()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

path/case → snake_case


## Source

```bash
string::path_to_snake() {
	local input; _string::read_input input "$@"
	echo "${input//\//_}"
}
```


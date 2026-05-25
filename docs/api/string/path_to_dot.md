# `string::path_to_dot`

**Signature:** `string::path_to_dot()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

path/case → dot.case


## Source

```bash
string::path_to_dot() {
	local input; _string::read_input input "$@"
	echo "${input//\//.}"
}
```


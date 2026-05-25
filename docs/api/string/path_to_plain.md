# `string::path_to_plain`

**Signature:** `string::path_to_plain()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

path/case → plain


## Source

```bash
string::path_to_plain() {
	local input; _string::read_input input "$@"
	echo "${input//\// }"
}
```


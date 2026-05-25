# `string::dot_to_plain`

**Signature:** `string::dot_to_plain()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

dot.case → plain


## Source

```bash
string::dot_to_plain() {
	local input; _string::read_input input "$@"
	echo "${input//./ }"
}
```


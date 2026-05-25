# `string::kebab_to_plain`

**Signature:** `string::kebab_to_plain()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

kebab-case → plain


## Source

```bash
string::kebab_to_plain() {
	local input; _string::read_input input "$@"
	echo "${input//-/ }"
}
```


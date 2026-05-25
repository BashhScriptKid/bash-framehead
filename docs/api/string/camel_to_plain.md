# `string::camel_to_plain`

**Signature:** `string::camel_to_plain()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

camelCase → plain


## Source

```bash
string::camel_to_plain() {
	local input; _string::read_input input "$@"
	_string::to_words "$input"
}
```


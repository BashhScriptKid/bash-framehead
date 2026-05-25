# `string::pascal_to_camel`

**Signature:** `string::pascal_to_camel()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

PascalCase → camelCase


## Source

```bash
string::pascal_to_camel() {
	local input; _string::read_input input "$@"
	local words
	words=$(_string::to_words "$input")
	string::plain_to_camel "$words"
}
```


# `string::camel_to_pascal`

**Signature:** `string::camel_to_pascal()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

camelCase → PascalCase


## Source

```bash
string::camel_to_pascal() {
	local input; _string::read_input input "$@"
	string::plain_to_pascal "$(_string::to_words "$input")"
}
```


# `string::pascal_to_snake`

**Signature:** `string::pascal_to_snake()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

PascalCase → snake_case


## Source

```bash
string::pascal_to_snake() {
	local input; _string::read_input input "$@"
	string::camel_to_snake "$input"
}
```


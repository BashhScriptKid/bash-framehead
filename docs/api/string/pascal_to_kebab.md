# `string::pascal_to_kebab`

**Signature:** `string::pascal_to_kebab()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

PascalCase → kebab-case


## Source

```bash
string::pascal_to_kebab() {
	local input; _string::read_input input "$@"
	string::camel_to_kebab "$input"
}
```


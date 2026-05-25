# `string::pascal_to_path`

**Signature:** `string::pascal_to_path()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

PascalCase → path/case


## Source

```bash
string::pascal_to_path() {
	local input; _string::read_input input "$@"
	string::camel_to_path "$input"
}
```


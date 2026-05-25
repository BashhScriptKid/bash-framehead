# `string::dot_to_pascal`

**Signature:** `string::dot_to_pascal()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

dot.case → PascalCase


## Source

```bash
string::dot_to_pascal() {
	local input; _string::read_input input "$@"
	string::plain_to_pascal "${input//./ }"
}
```


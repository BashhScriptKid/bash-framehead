# `string::pascal_to_constant`

**Signature:** `string::pascal_to_constant()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

PascalCase → CONSTANT_CASE


## Source

```bash
string::pascal_to_constant() {
  local input; _string::read_input input "$@"
  string::camel_to_constant "$input"
}
```


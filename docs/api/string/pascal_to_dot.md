# `string::pascal_to_dot`

**Signature:** `string::pascal_to_dot()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

PascalCase → dot.case


## Source

```bash
string::pascal_to_dot() {
  local input; _string::read_input input "$@"
  string::camel_to_dot "$input"
}
```


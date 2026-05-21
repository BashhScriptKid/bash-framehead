# `string::constant_to_camel`

**Signature:** `string::constant_to_camel()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

CONSTANT_CASE → camelCase


## Source

```bash
string::constant_to_camel() {
  local input; _string::read_input input "$@"
  string::snake_to_camel "${input,,}"
}
```


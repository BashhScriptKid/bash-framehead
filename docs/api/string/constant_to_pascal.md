# `string::constant_to_pascal`

**Signature:** `string::constant_to_pascal()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

CONSTANT_CASE → PascalCase


## Source

```bash
string::constant_to_pascal() {
  local input; _string::read_input input "$@"
  string::snake_to_pascal "${input,,}"
}
```


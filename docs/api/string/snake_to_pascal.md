# `string::snake_to_pascal`

**Signature:** `string::snake_to_pascal()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

snake_case → PascalCase


## Source

```bash
string::snake_to_pascal() {
  local input; _string::read_input input "$@"
  string::plain_to_pascal "${input//_/ }"
}
```


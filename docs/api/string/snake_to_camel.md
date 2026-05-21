# `string::snake_to_camel`

**Signature:** `string::snake_to_camel()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

snake_case → camelCase


## Source

```bash
string::snake_to_camel() {
  local input; _string::read_input input "$@"
  string::plain_to_camel "${input//_/ }"
}
```


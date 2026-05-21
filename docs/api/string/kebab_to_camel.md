# `string::kebab_to_camel`

**Signature:** `string::kebab_to_camel()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

kebab-case → camelCase


## Source

```bash
string::kebab_to_camel() {
  local input; _string::read_input input "$@"
  string::plain_to_camel "${input//-/ }"
}
```


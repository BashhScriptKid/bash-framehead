# `string::snake_to_plain`

**Signature:** `string::snake_to_plain()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

snake_case → plain


## Source

```bash
string::snake_to_plain() {
  local input; _string::read_input input "$@"
  echo "${input//_/ }"
}
```


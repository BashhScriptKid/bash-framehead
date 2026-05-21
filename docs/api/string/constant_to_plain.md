# `string::constant_to_plain`

**Signature:** `string::constant_to_plain()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

CONSTANT_CASE → plain


## Source

```bash
string::constant_to_plain() {
  local input; _string::read_input input "$@"
  local s="${input//_/ }"
  echo "${s,,}"
}
```


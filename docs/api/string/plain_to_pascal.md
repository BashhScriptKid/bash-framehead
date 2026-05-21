# `string::plain_to_pascal`

**Signature:** `string::plain_to_pascal()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

plain → PascalCase


## Source

```bash
string::plain_to_pascal() {
  local input; _string::read_input input "$@"
  local result=""
  for word in $input; do result+="${word^}"; done
  echo "$result"
}
```


# `string::is_alnum`

**Signature:** `string::is_alnum()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string is alphanumeric only


## Source

```bash
string::is_alnum() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^[a-zA-Z0-9]+$ ]]
}
```


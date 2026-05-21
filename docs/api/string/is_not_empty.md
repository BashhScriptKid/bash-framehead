# `string::is_not_empty`

**Signature:** `string::is_not_empty()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string is non-empty


## Source

```bash
string::is_not_empty() {
  local input; _string::read_input input "$@"
  [[ -n "$input" ]]
}
```


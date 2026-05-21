# `string::is_empty`

**Signature:** `string::is_empty()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if string is empty


## Source

```bash
string::is_empty() {
  local input; _string::read_input input "$@"
  [[ -z "$input" ]]
}
```


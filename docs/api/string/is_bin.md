# `string::is_bin`

**Signature:** `string::is_bin()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
string::is_bin() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^0b[01]+$ ]]
}
```


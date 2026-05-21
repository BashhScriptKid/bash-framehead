# `string::is_hex`

**Signature:** `string::is_hex()`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
string::is_hex() {
  local input; _string::read_input input "$@"
  [[ "$input" =~ ^(0[xX])?[0-9A-Fa-f]+$ ]]
}
```


# `string::lower::legacy`

**Signature:** `string::lower::legacy()`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Convert to lowercase (Bash 3 compatible)


## Source

```bash
string::lower::legacy() {
  local input; _string::read_input input "$@"
  echo "$input" | tr '[:upper:]' '[:lower:]'
}
```


# `string::join::fast`

**Signature:** `string::join::fast(result_var, delimiter, arg1, arg2, ...)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `delimiter` | string | Yes | |
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `...` | any | — | |

## Source

```bash
string::join::fast() {
  local -n _string_join_result="$1"
  local delim="$2"
  shift 2
  local result=""
  local first=true
  for part in "$@"; do
    if $first; then
      result="$part"
      first=false
    else
      result+="${delim}${part}"
    fi
  done
  _string_join_result="$result"
}
```


# `string::repeat::fast`

**Signature:** `string::repeat::fast(result_var, str, n)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |
| `n` | integer | Yes | |

## Source

```bash
string::repeat::fast() {
  local -n _string_repeat_result="$1"
  local str="$2" n="$3" result=""
  for ((i = 0; i < n; i++)); do result+="$str"; done
  _string_repeat_result="$result"
}
```


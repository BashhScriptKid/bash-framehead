# `string::pad_left::fast`

**Signature:** `string::pad_left::fast(result_var, str, width, [char])`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |
| `width` | string | Yes | |
| `char` | string | No | |

## Source

```bash
string::pad_left::fast() {
  local -n _string_pad_left_result="$1"
  local s="$2" width="$3" char="${4:- }"
  local len="${#s}"
  if ((len >= width)); then
    _string_pad_left_result="$s"
    return
  fi
  local pad result=""
  for ((i = 0; i < width - len; i++)); do result+="$char"; done
  _string_pad_left_result="${result}${s}"
}
```


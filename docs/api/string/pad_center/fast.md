# `string::pad_center::fast`

**Signature:** `string::pad_center::fast(result_var, str, width, [char])`

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
string::pad_center::fast() {
  local -n _string_pad_center_result="$1"
  local s="$2" width="$3" char="${4:- }"
  local len="${#s}"
  if ((len >= width)); then
    _string_pad_center_result="$s"
    return
  fi
  local total=$((width - len))
  local left=$((total / 2))
  local right=$((total - left))
  local lpad="" rpad=""
  for ((i = 0; i < left; i++)); do lpad+="$char"; done
  for ((i = 0; i < right; i++)); do rpad+="$char"; done
  _string_pad_center_result="${lpad}${s}${rpad}"
}
```


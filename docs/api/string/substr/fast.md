# `string::substr::fast`

**Signature:** `string::substr::fast(result_var, str, start, [length])`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |
| `start` | string | Yes | |
| `length` | string | No | |

## Source

```bash
string::substr::fast() {
  local -n _string_substr_result="$1"
  local s="$2" start="$3" len="${4:-}"
  if [[ -n "$len" ]]; then
    _string_substr_result="${s:$start:$len}"
  else
    _string_substr_result="${s:$start}"
  fi
}
```


# `string::strip_spaces::fast`

**Signature:** `string::strip_spaces::fast(result_var, str)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |

## Source

```bash
string::strip_spaces::fast() {
  local -n _string_strip_spaces_result="$1"
  _string_strip_spaces_result="${2//[[:space:]]/}"
}
```


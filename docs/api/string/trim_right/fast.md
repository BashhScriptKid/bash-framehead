# `string::trim_right::fast`

**Signature:** `string::trim_right::fast(result_var, str)`

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
string::trim_right::fast() {
  local -n _string_trim_right_result="$1"
  _string_trim_right_result="${2%"${2##*[![:space:]]}"}"
}
```


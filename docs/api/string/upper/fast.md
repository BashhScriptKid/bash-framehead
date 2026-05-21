# `string::upper::fast`

**Signature:** `string::upper::fast(result_var, str)`

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
string::upper::fast() {
  local -n _string_upper_result="$1"
  _string_upper_result="${2^^}"
}
```


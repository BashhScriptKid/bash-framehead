# `string::remove::fast`

**Signature:** `string::remove::fast(result_var, str, substring)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |
| `substring` | string | Yes | |

## Source

```bash
string::remove::fast() {
  local -n _string_remove_result="$1"
  _string_remove_result="${2//"$3"/}"
}
```


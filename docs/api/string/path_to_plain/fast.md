# `string::path_to_plain::fast`

**Signature:** `string::path_to_plain::fast(result_var, arg1)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |

## Source

```bash
string::path_to_plain::fast() {
  local -n _string_path_to_plain_result="$1"
  _string_path_to_plain_result="${2//\// }"
}
```


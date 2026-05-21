# `string::replace_all::fast`

**Signature:** `string::replace_all::fast(result_var, str, search, replace)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |
| `search` | string | Yes | |
| `replace` | string | Yes | |

## Source

```bash
string::replace_all::fast() {
  local -n _string_replace_all_result="$1"
  _string_replace_all_result="${2//"$3"/"$4"}"
}
```


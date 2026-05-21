# `string::title::fast`

**Signature:** `string::title::fast(result_var, str)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref (requires awk)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `str` | string | Yes | |

## Source

```bash
string::title::fast() {
  local -n _string_title_result="$1"
  _string_title_result=$(echo "$2" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}')
}
```


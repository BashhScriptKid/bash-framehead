# `string::kebab_to_pascal::fast`

**Signature:** `string::kebab_to_pascal::fast(result_var, arg1)`

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
string::kebab_to_pascal::fast() {
  local -n _string_kebab_to_pascal_result="$1"
  local result=""
  for word in ${2//-/ }; do result+="${word^}"; done
  _string_kebab_to_pascal_result="$result"
}
```


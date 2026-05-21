# `string::kebab_to_camel::fast`

**Signature:** `string::kebab_to_camel::fast(result_var, arg1)`

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
string::kebab_to_camel::fast() {
  local -n _string_kebab_to_camel_result="$1"
  local words="${2//-/ }"
  local result="" first=true
  for word in $words; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  _string_kebab_to_camel_result="$result"
}
```


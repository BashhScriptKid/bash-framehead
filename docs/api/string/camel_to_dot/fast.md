# `string::camel_to_dot::fast`

**Signature:** `string::camel_to_dot::fast(result_var, arg1, arg2)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
string::camel_to_dot::fast() {
  local -n _string_camel_to_dot_result="$1"
  local s="$2"
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  s="${s,,}"
  _string_camel_to_dot_result="${s// /.}"
}
```


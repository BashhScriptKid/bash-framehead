# `string::plain_to_snake::fast`

**Signature:** `string::plain_to_snake::fast(result_var, hello, world)`

**Module:** [`string`](../../string.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

Fast variant using nameref

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `result_var` | variable | Yes | |
| `hello` | string | Yes | |
| `world` | string | Yes | |

## Source

```bash
string::plain_to_snake::fast() {
  local -n _string_plain_to_snake_result="$1"
  _string_plain_to_snake_result="${2// /_}"
  _string_plain_to_snake_result="${_string_plain_to_snake_result,,}"
}
```


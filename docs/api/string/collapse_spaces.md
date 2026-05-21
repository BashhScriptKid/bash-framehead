# `string::collapse_spaces`

**Signature:** `string::collapse_spaces(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Collapse multiple consecutive spaces into one

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::collapse_spaces() {
  local input; _string::read_input input "$@"
  echo "$input" | tr -s ' '
}
```


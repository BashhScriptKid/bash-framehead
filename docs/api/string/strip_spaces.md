# `string::strip_spaces`

**Signature:** `string::strip_spaces(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Remove all whitespace

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::strip_spaces() {
  local input; _string::read_input input "$@"
  echo "${input//[[:space:]]/}"
}
```


# `string::trim_left`

**Signature:** `string::trim_left(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Trim leading whitespace

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::trim_left() {
  local input; _string::read_input input "$@"
  input="${input#"${input%%[![:space:]]*}"}"
  echo "$input"
}
```


# `string::length`

**Signature:** `string::length(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Length of a string

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::length() {
  local input; _string::read_input input "$@"
  echo "${#input}"
}
```


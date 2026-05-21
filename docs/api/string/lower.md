# `string::lower`

**Signature:** `string::lower(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Convert to lowercase

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::lower() {
  local input; _string::read_input input "$@"
  echo "${input,,}"
}
```


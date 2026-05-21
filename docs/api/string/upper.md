# `string::upper`

**Signature:** `string::upper(str)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Convert to uppercase

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |

## Source

```bash
string::upper() {
  local input; _string::read_input input "$@"
  echo "${input^^}"
}
```


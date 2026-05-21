# `string::before`

**Signature:** `string::before(str, delimiter)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Return everything before the first occurrence of delimiter

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `delimiter` | string | Yes | |

## Source

```bash
string::before() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; shift; fi
  echo "${input%%"$1"*}"
}
```


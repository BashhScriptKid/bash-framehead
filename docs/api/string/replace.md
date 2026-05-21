# `string::replace`

**Signature:** `string::replace(str, search, replace)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Replace first occurrence of search with replace

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `search` | string | Yes | |
| `replace` | string | Yes | |

## Source

```bash
string::replace() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; shift; fi
  echo "${input/"$1"/"$2"}"
}
```


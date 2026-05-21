# `string::replace_all`

**Signature:** `string::replace_all(str, search, replace)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Replace all occurrences of search with replace

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `search` | string | Yes | |
| `replace` | string | Yes | |

## Source

```bash
string::replace_all() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; shift; fi
  echo "${input//"$1"/"$2"}"
}
```


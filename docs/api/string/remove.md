# `string::remove`

**Signature:** `string::remove(str, substring)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Remove all occurrences of a substring

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `substring` | string | Yes | |

## Source

```bash
string::remove() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; shift; fi
  echo "${input//"$1"/}"
}
```


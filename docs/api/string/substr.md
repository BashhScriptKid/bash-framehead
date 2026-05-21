# `string::substr`

**Signature:** `string::substr(str, start, [length])`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Extract substring

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `start` | string | Yes | |
| `length` | string | No | |

## Source

```bash
string::substr() {
  local input start len
  if [[ ! -t 0 ]]; then
    input=$(cat); start="$1"; len="${2:-}"
  else
    input="$1"; start="$2"; len="${3:-}"
  fi
  if [[ -n "$len" ]]; then
    echo "${input:$start:$len}"
  else
    echo "${input:$start}"
  fi
}
```


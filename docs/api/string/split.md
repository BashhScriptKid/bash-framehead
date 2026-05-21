# `string::split`

**Signature:** `string::split(str, delimiter)`

**Module:** [`string`](../string.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Split a string by delimiter into lines (one element per line)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `str` | string | Yes | |
| `delimiter` | string | Yes | |

## Source

```bash
string::split() {
  local input delim
  if [[ ! -t 0 ]]; then
    input=$(cat); delim="$1"
  else
    input="$1"; delim="$2"
  fi
  local IFS="$delim"
  set -- $input
  printf '%s\n' "$@"
}
```


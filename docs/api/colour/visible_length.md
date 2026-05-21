# `colour::visible_length`

**Signature:** `colour::visible_length(arg1)`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Return the visible length of a string (excluding escape codes)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
colour::visible_length() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; fi
  local stripped
  stripped=$(colour::strip "$input")
  echo "${#stripped}"
}
```


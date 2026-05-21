# `colour::has_colour`

**Signature:** `colour::has_colour(arg1)`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Check if a string contains any ANSI escape codes

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
colour::has_colour() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; fi
  [[ "$input" =~ $'\033'\[ ]]
}
```


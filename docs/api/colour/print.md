# `colour::print`

**Signature:** `colour::print(bit, fg_bg, colour, text)`

**Module:** [`colour`](../colour.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Print text wrapped in colour, auto-reset after

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bit` | string | Yes | |
| `fg_bg` | string | Yes | |
| `colour` | string | Yes | |
| `text` | string | Yes | |

## Source

```bash
colour::print() {
  local bit="$1" fg_bg="$2" col="$3" text
  if [[ ! -t 0 ]]; then text=$(cat); else text="$4"; fi
  colour::esc "$bit" "$fg_bg" "$col"
  printf '%s' "$text"
  colour::reset
}
```


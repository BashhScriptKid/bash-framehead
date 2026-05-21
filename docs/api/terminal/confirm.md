# `terminal::confirm`

**Signature:** `terminal::confirm(Are, you, sure?)`

**Module:** [`terminal`](../terminal.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Prompt user for y/n, returns 0 for yes, 1 for no

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `Are` | string | Yes | |
| `you` | string | Yes | |
| `sure?` | string | Yes | |

## Source

```bash
terminal::confirm() {
    local prompt="${1:-Are you sure?} [y/N] "
    local key
    printf '%s' "$prompt"
    terminal::read_key key
    printf '\n'
    [[ "${key,,}" == "y" ]]
}
```


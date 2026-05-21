# `terminal::confirm::default`

**Signature:** `terminal::confirm::default(yes, Proceed?)`

**Module:** [`terminal`](../../terminal.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Prompt with a default choice shown

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `yes` | string | Yes | |
| `Proceed?` | string | Yes | |

## Source

```bash
terminal::confirm::default() {
    local default="${1:-yes}" prompt="${2:-Are you sure?}"
    local label
    [[ "$default" == "yes" ]] && label="[Y/n]" || label="[y/N]"
    printf '%s %s ' "$prompt" "$label"
    local key
    terminal::read_key key
    printf '\n'
    if [[ -z "$key" ]]; then
        [[ "$default" == "yes" ]]
    else
        [[ "${key,,}" == "y" ]]
    fi
}
```


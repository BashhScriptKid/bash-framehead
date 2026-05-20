# `terminal::confirm::default`

Prompt with a default choice shown

## Usage

```bash
terminal::confirm::default yes "Proceed?"
```

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

## Module

[`terminal`](../terminal.md)

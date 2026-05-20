# `terminal::confirm`

Prompt user for y/n, returns 0 for yes, 1 for no

## Usage

```bash
terminal::confirm "Are you sure?"
```

> [!NOTE]
> Will return 1 on non-'y' input (defaults to no)

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

## Module

[`terminal`](../terminal.md)

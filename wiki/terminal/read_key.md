# `terminal::read_key`

Read a single keypress without requiring Enter

## Usage

```bash
terminal::read_key varname
```

## Source

```bash
terminal::read_key() {
    local _var="${1:-_TERMINAL_KEY}"
    local _key
    IFS= read -r -s -n1 _key
    printf -v "$_var" '%s' "$_key"
}
```

## Module

[`terminal`](../terminal.md)

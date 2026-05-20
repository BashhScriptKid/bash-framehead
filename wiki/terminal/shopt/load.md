# `terminal::shopt::load`

Restore state from a variable

## Usage

```bash
terminal::shopt::load varname
```

## Source

```bash
terminal::shopt::load() {
    local _var="${1:-_SHOPT_STATE}"
    eval "${!_var}"
}
```

## Module

[`terminal`](../terminal.md)

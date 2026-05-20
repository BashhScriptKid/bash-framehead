# `terminal::read_key::timeout`

Read a single keypress with a timeout

## Usage

```bash
terminal::read_key::timeout varname seconds
```

## Source

```bash
terminal::read_key::timeout() {
    local _var="${1:-_TERMINAL_KEY}" _timeout="${2:-5}"
    local _key
    IFS= read -r -s -n1 -t "$_timeout" _key
    printf -v "$_var" '%s' "$_key"
}
```

## Module

[`terminal`](../terminal.md)

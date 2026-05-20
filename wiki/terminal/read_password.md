# `terminal::read_password`

Read a password (no echo)

## Usage

```bash
terminal::read_password varname [prompt]
```

## Source

```bash
terminal::read_password() {
    local _var="$1" _prompt="${2:-Password: }"
    local _pass
    printf '%s' "$_prompt"
    terminal::echo::off
    IFS= read -r _pass
    terminal::echo::on
    printf '\n'
    printf -v "$_var" '%s' "$_pass"
}
```

## Module

[`terminal`](../terminal.md)

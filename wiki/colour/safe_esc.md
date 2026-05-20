# `colour::safe_esc`

Gracefully degrade — return escape code only if terminal supports the depth

## Usage

```bash
colour::safe_esc bit fg_bg colour
```
Returns empty string (no-op) if terminal doesn't support the requested depth

## Source

```bash
colour::safe_esc() {
    local bit="$1"
    case "$bit" in
    4)  colour::supports     || return 0 ;;
    8)  colour::supports_256 || return 0 ;;
    24) colour::supports_truecolor || return 0 ;;
    esac
    colour::esc "$@"
}
```

## Module

[`colour`](../colour.md)

# `colour::print`

Print text wrapped in colour, auto-reset after

## Usage

```bash
colour::print bit fg_bg colour text
```

## Example

```bash
colour::print 4 fg red "Hello"
```

## Source

```bash
colour::print() {
    local bit="$1" fg_bg="$2" col="$3" text="$4"
    colour::esc "$bit" "$fg_bg" "$col"
    printf '%s' "$text"
    colour::reset
}
```

## Module

[`colour`](../colour.md)

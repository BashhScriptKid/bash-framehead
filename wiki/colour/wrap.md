# `colour::wrap`

Wrap text in escape codes and return as string (no direct print)

## Usage

```bash
colour::wrap bit fg_bg colour text
```

## Source

```bash
colour::wrap() {
    local bit="$1" fg_bg="$2" col="$3" text="$4"
    printf '%s%s%s' "$(colour::esc "$bit" "$fg_bg" "$col")" "$text" "$(colour::reset)"
}
```

## Module

[`colour`](../colour.md)

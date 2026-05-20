# `terminal::title`

Set terminal title (works in most modern terminal emulators)

## Usage

```bash
terminal::title "My Script"
```

## Source

```bash
terminal::title() {
    printf '\033]0;%s\007' "$1"
}
```

## Module

[`terminal`](../terminal.md)

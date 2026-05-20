# `terminal::cursor::move`

Move cursor to row, col (1-indexed)

## Usage

```bash
terminal::cursor::move row col
```

## Source

```bash
terminal::cursor::move() {
    printf '\033[%s;%sH' "$1" "$2"
}
```

## Module

[`terminal`](../terminal.md)

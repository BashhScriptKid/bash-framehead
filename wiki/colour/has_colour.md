# `colour::has_colour`

Check if a string contains any ANSI escape codes

## Source

```bash
colour::has_colour() {
    [[ "$1" =~ $'\033'\[ ]]
}
```

## Module

[`colour`](../colour.md)

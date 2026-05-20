# `colour::strip`

Strip all ANSI escape codes from a string

## Usage

```bash
colour::strip text
```

## Source

```bash
colour::strip() {
    echo "$1" | sed 's/\x1b\[[0-9;]*[mGKHF]//g'
}
```

## Module

[`colour`](../colour.md)

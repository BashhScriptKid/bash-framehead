# `array::from_lines`

Build an array from lines of stdin or a string (newline-delimited)

## Usage

```bash
array::from_lines "line1\nline2\nline3"
```

## Source

```bash
array::from_lines() {
    local IFS=$'\n'
    local -a parts=($1)
    printf '%s\n' "${parts[@]}"
}
```

## Module

[`array`](../array.md)

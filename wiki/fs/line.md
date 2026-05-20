# `fs::line`

Read a specific line number (1-indexed)

## Usage

```bash
fs::line path line_number
```

## Source

```bash
fs::line() {
    sed -n "${2}p" "$1"
}
```

## Module

[`fs`](../fs.md)

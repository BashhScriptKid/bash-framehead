# `fs::contains`

Check if file contains a string

## Usage

```bash
fs::contains path string
```

## Source

```bash
fs::contains() {
    grep -qF "$2" "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

# `fs::find`

Recursive find by name pattern

## Usage

```bash
fs::find path pattern
```

## Source

```bash
fs::find() {
    find "${1:-.}" -name "$2" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

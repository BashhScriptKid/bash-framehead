# `fs::write`

Write content to file (overwrites)

## Usage

```bash
fs::write path content
```

## Source

```bash
fs::write() {
    printf '%s' "$2" > "$1"
}
```

## Module

[`fs`](../fs.md)

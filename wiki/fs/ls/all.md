# `fs::ls::all`

List with hidden files

## Source

```bash
fs::ls::all() {
    ls -1A "${1:-.}"
}
```

## Module

[`fs`](../fs.md)

# `fs::ls`

List directory contents (one per line)

## Source

```bash
fs::ls() {
    ls -1 "${1:-.}"
}
```

## Module

[`fs`](../fs.md)

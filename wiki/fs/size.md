# `fs::size`

File size in bytes

## Source

```bash
fs::size() {
    stat -c '%s' "$1" 2>/dev/null || wc -c < "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

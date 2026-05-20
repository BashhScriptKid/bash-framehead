# `fs::inode`

Inode number

## Source

```bash
fs::inode() {
    stat -c '%i' "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

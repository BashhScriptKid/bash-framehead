# `fs::is_same`

Check if two paths resolve to the same file (inode comparison)

## Source

```bash
fs::is_same() {
    [[ "$(stat -c '%d:%i' "$1" 2>/dev/null)" == "$(stat -c '%d:%i' "$2" 2>/dev/null)" ]]
}
```

## Module

[`fs`](../fs.md)

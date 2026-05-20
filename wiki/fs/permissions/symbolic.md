# `fs::permissions::symbolic`

Symbolic permissions (e.g. -rwxr-xr-x)

## Source

```bash
fs::permissions::symbolic() {
    stat -c '%A' "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

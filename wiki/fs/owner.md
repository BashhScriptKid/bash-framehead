# `fs::owner`

Owner username

## Source

```bash
fs::owner() {
    stat -c '%U' "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

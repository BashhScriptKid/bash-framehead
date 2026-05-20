# `fs::created`

Creation time (unix timestamp) — not available on all filesystems

## Source

```bash
fs::created() {
    stat -c '%W' "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

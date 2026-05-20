# `fs::link_count`

Number of hard links

## Source

```bash
fs::link_count() {
    stat -c '%h' "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

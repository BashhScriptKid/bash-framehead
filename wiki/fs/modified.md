# `fs::modified`

Last modified time (unix timestamp)

## Source

```bash
fs::modified() {
    stat -c '%Y' "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

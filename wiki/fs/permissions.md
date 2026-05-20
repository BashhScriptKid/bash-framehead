# `fs::permissions`

Octal permissions

## Source

```bash
fs::permissions() {
    stat -c '%a' "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

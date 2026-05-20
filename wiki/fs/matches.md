# `fs::matches`

Check if file matches a regex

## Source

```bash
fs::matches() {
    grep -qE "$2" "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

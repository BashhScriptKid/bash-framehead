# `fs::owner::group`

Owner group

## Source

```bash
fs::owner::group() {
    stat -c '%G' "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

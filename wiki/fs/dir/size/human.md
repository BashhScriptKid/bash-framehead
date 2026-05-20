# `fs::dir::size::human`

Get total size of directory, human readable

## Source

```bash
fs::dir::size::human() {
    du -sh "${1:-.}" 2>/dev/null | awk '{print $1}'
}
```

## Module

[`fs`](../fs.md)

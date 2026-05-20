# `fs::dir::count`

Count items in directory

## Source

```bash
fs::dir::count() {
    find "${1:-.}" -maxdepth 1 -not -path "${1:-.}" 2>/dev/null | wc -l
}
```

## Module

[`fs`](../fs.md)

# `fs::ls::dirs`

List only directories

## Source

```bash
fs::ls::dirs() {
    find "${1:-.}" -maxdepth 1 -type d -not -path "${1:-.}" -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep '/$' | tr -d '/'
}
```

## Module

[`fs`](../fs.md)

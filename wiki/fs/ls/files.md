# `fs::ls::files`

List only files

## Source

```bash
fs::ls::files() {
    find "${1:-.}" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep -v '/$'
}
```

## Module

[`fs`](../fs.md)

# `fs::prepend`

Prepend content to file

## Source

```bash
fs::prepend() {
    local tmp
    tmp=$(fs::temp::file)
    printf '%s\n' "$2" | cat - "$1" > "$tmp"
    mv "$tmp" "$1"
}
```

## Module

[`fs`](../fs.md)

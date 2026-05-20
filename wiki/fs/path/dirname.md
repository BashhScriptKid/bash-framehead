# `fs::path::dirname`

Get directory from path (like dirname)

## Source

```bash
fs::path::dirname() {
    local p="${1%/*}"
    [[ "$p" == "$1" ]] && echo "." || echo "$p"
}
```

## Module

[`fs`](../fs.md)

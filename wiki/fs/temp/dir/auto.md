# `fs::temp::dir::auto`

Create a temp dir and register cleanup on EXIT

## Source

```bash
fs::temp::dir::auto() {
    local tmp
    tmp=$(fs::temp::dir "$1")
    trap "rm -rf '$tmp'" EXIT
    echo "$tmp"
}
```

## Module

[`fs`](../fs.md)

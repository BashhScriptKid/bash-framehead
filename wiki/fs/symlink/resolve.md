# `fs::symlink::resolve`

Resolved symlink target (follows chain)

## Source

```bash
fs::symlink::resolve() {
    readlink -f "$1" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

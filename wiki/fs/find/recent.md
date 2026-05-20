# `fs::find::recent`

Find files modified within n minutes

## Source

```bash
fs::find::recent() {
    find "${1:-.}" -type f -mmin "-${2:-60}" 2>/dev/null
}
```

## Module

[`fs`](../fs.md)

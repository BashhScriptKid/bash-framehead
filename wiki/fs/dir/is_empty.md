# `fs::dir::is_empty`

Check if directory is empty

## Source

```bash
fs::dir::is_empty() {
    [[ -z "$(ls -A "${1:-.}" 2>/dev/null)" ]]
}
```

## Module

[`fs`](../fs.md)

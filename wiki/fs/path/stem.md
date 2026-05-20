# `fs::path::stem`

Strip extension from filename

## Source

```bash
fs::path::stem() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base%.*}" || echo "$base"
}
```

## Module

[`fs`](../fs.md)

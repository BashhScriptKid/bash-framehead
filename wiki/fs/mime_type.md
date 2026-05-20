# `fs::mime_type`

MIME type

## Source

```bash
fs::mime_type() {
    if runtime::has_command file; then
        file --mime-type -b "$1" 2>/dev/null
    else
        echo "unknown"
    fi
}
```

## Module

[`fs`](../fs.md)

# `fs::trash`

Safely delete to a trash dir instead of permanent delete

## Usage

```bash
fs::trash path
```

## Source

```bash
fs::trash() {
    local trash_dir="${HOME}/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    mv "$1" "$trash_dir/$(fs::path::basename "$1").$(date +%s)"
}
```

## Module

[`fs`](../fs.md)

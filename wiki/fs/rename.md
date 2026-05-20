# `fs::rename`

Rename just the filename, keeping directory

## Usage

```bash
fs::rename old_path new_name
```

## Source

```bash
fs::rename() {
    local dir
    dir="$(fs::path::dirname "$1")"
    mv "$1" "$dir/$2"
}
```

## Module

[`fs`](../fs.md)

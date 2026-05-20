# `fs::path::extensions`

Get all extensions for multi-part extensions

## Usage

```bash
fs::path::extensions file.tar.gz → tar.gz
```

## Source

```bash
fs::path::extensions() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base#*.}" || echo ""
}
```

## Module

[`fs`](../fs.md)

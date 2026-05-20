# `fs::path::relative`

Get path relative to a base

## Usage

```bash
fs::path::relative /a/b/c /a → b/c
```

## Source

```bash
fs::path::relative() {
    local target="$1" base="$2"
    # Strip common prefix
    while [[ "$target" == "$base"* && "$base" != "/" ]]; do
        target="${target#$base}"
        target="${target#/}"
        break
    done
    echo "$target"
}
```

## Module

[`fs`](../fs.md)

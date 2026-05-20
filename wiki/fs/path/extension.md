# `fs::path::extension`

Get file extension (without dot)

## Usage

```bash
fs::path::extension file.tar.gz → gz
```

## Source

```bash
fs::path::extension() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base##*.}" || echo ""
}
```

## Module

[`fs`](../fs.md)

# `fs::temp::file`

Create a temporary file, print its path

## Usage

```bash
tmpfile=$(fs::temp::file [prefix])
```

## Source

```bash
fs::temp::file() {
    local prefix="${1:-fsbshf}"
    mktemp "/tmp/${prefix}.XXXXXX"
}
```

## Module

[`fs`](../fs.md)

# `fs::temp::dir`

Create a temporary directory, print its path

## Usage

```bash
tmpdir=$(fs::temp::dir [prefix])
```

## Source

```bash
fs::temp::dir() {
    local prefix="${1:-fsbshf}"
    mktemp -d "/tmp/${prefix}.XXXXXX"
}
```

## Module

[`fs`](../fs.md)

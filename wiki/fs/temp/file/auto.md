# `fs::temp::file::auto`

Create a temp file and register cleanup on EXIT

## Usage

```bash
fs::temp::file::auto [prefix]
```

## Source

```bash
fs::temp::file::auto() {
    local tmp
    tmp=$(fs::temp::file "$1")
    trap "rm -f '$tmp'" EXIT
    echo "$tmp"
}
```

## Module

[`fs`](../fs.md)

# `fs::path::join`

Join path components

## Usage

```bash
fs::path::join part1 part2 ...
```

## Source

```bash
fs::path::join() {
    local result="$1"; shift
    for part in "$@"; do
        part="${part#/}"   # strip leading slash from each part
        result="${result%/}/$part"
    done
    echo "$result"
}
```

## Module

[`fs`](../fs.md)

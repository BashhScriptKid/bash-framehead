# `fs::lines`

Read a range of lines

## Usage

```bash
fs::lines path start end
```

## Source

```bash
fs::lines() {
    sed -n "${2},${3}p" "$1"
}
```

## Module

[`fs`](../fs.md)

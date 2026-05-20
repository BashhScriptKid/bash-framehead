# `fs::copy`

Copy file or directory

## Usage

```bash
fs::copy src dst
```

## Source

```bash
fs::copy() {
    cp -r "$1" "$2"
}
```

## Module

[`fs`](../fs.md)

# `fs::symlink`

Create a symlink

## Usage

```bash
fs::symlink target link_name
```

## Source

```bash
fs::symlink() {
    ln -s "$1" "$2"
}
```

## Module

[`fs`](../fs.md)

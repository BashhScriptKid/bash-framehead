# `fs::replace`

Replace string in file (in-place)

## Usage

```bash
fs::replace path old new
```

## Source

```bash
fs::replace() {
    sed -i "s|${2}|${3}|g" "$1"
}
```

## Module

[`fs`](../fs.md)

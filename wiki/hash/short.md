# `hash::short`

Generate a short hash — first n chars of sha256

## Usage

```bash
hash::short string [length]
```

## Source

```bash
hash::short() {
    local s="$1" len="${2:-8}"
    local full
    full=$(hash::sha256 "$s") || return 1
    echo "${full:0:$len}"
}
```

## Module

[`hash`](../hash.md)

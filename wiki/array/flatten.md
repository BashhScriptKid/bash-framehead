# `array::flatten`

Flatten one level — splits each element by whitespace

## Usage

```bash
array::flatten el1 "el2a el2b" el3
```

## Source

```bash
array::flatten() {
    for el in "$@"; do
        for word in $el; do
            echo "$word"
        done
    done
}
```

## Module

[`array`](../array.md)

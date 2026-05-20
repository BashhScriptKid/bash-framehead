# `array::remove`

Remove all occurrences of a value

## Usage

```bash
array::remove value el1 el2 ...
```

## Source

```bash
array::remove() {
    local target="$1"; shift
    for el in "$@"; do
        [[ "$el" != "$target" ]] && echo "$el"
    done
}
```

## Module

[`array`](../array.md)

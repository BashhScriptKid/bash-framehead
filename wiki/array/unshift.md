# `array::unshift`

Prepend an element

## Usage

```bash
array::unshift new_el el1 el2 ...
```

## Source

```bash
array::unshift() {
    local new="$1"; shift
    printf '%s\n' "$new" "$@"
}
```

## Module

[`array`](../array.md)

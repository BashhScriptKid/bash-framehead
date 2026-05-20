# `array::push`

Append elements (print existing + new)

## Usage

```bash
array::push new_el el1 el2 ...
```

## Source

```bash
array::push() {
    local new="$1"; shift
    printf '%s\n' "$@" "$new"
}
```

## Module

[`array`](../array.md)

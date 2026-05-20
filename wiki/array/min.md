# `array::min`

Minimum value (numeric)

## Source

```bash
array::min() {
    local min="$1"; shift
    for el in "$@"; do
        (( el < min )) && min="$el"
    done
    echo "$min"
}
```

## Module

[`array`](../array.md)

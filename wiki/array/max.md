# `array::max`

Maximum value (numeric)

## Source

```bash
array::max() {
    local max="$1"; shift
    for el in "$@"; do
        (( el > max )) && max="$el"
    done
    echo "$max"
}
```

## Module

[`array`](../array.md)

# `array::sum`

Sum all numeric elements

## Usage

```bash
array::sum el1 el2 ...
```

## Source

```bash
array::sum() {
    local total=0
    for el in "$@"; do
        total=$(( total + el ))
    done
    echo "$total"
}
```

## Module

[`array`](../array.md)

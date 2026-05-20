# `array::pop`

Remove last element

## Usage

```bash
array::pop el1 el2 ...
```

## Source

```bash
array::pop() {
    local -a arr=("$@")
    unset 'arr[-1]'
    printf '%s\n' "${arr[@]}"
}
```

## Module

[`array`](../array.md)

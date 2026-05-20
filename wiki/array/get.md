# `array::get`

Return element at index

## Usage

```bash
array::get index el1 el2 ...
```

## Source

```bash
array::get() {
    local idx="$1"; shift
    local -a arr=("$@")
    echo "${arr[$idx]}"
}
```

## Module

[`array`](../array.md)

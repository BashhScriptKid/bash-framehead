# `array::slice`

Slice a subarray

## Usage

```bash
array::slice start length el1 el2 ...
```

## Source

```bash
array::slice() {
    local start="$1" len="$2"; shift 2
    local -a arr=("$@")
    printf '%s\n' "${arr[@]:$start:$len}"
}
```

## Module

[`array`](../array.md)

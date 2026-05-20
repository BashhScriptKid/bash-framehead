# `array::remove_at`

Remove element at index

## Usage

```bash
array::remove_at index el1 el2 ...
```

## Source

```bash
array::remove_at() {
    local idx="$1" i=0; shift
    for el in "$@"; do
        [[ "$i" -ne "$idx" ]] && echo "$el"
        (( i++ ))
    done
}
```

## Module

[`array`](../array.md)

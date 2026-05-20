# `array::insert_at`

Insert element at index

## Usage

```bash
array::insert_at index value el1 el2 ...
```

## Source

```bash
array::insert_at() {
    local idx="$1" val="$2" i=0; shift 2
    for el in "$@"; do
        [[ "$i" -eq "$idx" ]] && echo "$val"
        echo "$el"
        (( i++ ))
    done
    # If index is beyond end, append
    [[ "$i" -le "$idx" ]] && echo "$val"
}
```

## Module

[`array`](../array.md)

# `array::reject`

Filter elements NOT matching a regex

## Usage

```bash
array::reject regex el1 el2 ...
```

## Source

```bash
array::reject() {
    local regex="$1"; shift
    for el in "$@"; do
        [[ ! "$el" =~ $regex ]] && echo "$el"
    done
}
```

## Module

[`array`](../array.md)

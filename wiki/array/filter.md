# `array::filter`

Filter elements matching a regex

## Usage

```bash
array::filter regex el1 el2 ...
```

## Source

```bash
array::filter() {
    local regex="$1"; shift
    for el in "$@"; do
        [[ "$el" =~ $regex ]] && echo "$el"
    done
}
```

## Module

[`array`](../array.md)

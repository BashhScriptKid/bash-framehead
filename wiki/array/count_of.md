# `array::count_of`

Count occurrences of a value

## Usage

```bash
array::count_of needle el1 el2 ...
```

## Source

```bash
array::count_of() {
    local needle="$1" count=0; shift
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && (( count++ ))
    done
    echo "$count"
}
```

## Module

[`array`](../array.md)

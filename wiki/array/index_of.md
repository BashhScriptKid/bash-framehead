# `array::index_of`

Return index of first match (-1 if not found)

## Usage

```bash
array::index_of needle el1 el2 ...
```

## Source

```bash
array::index_of() {
    local needle="$1"; shift
    local i=0
    for el in "$@"; do
        [[ "$el" == "$needle" ]] && echo "$i" && return 0
        (( i++ ))
    done
    echo -1
    return 1
}
```

## Module

[`array`](../array.md)

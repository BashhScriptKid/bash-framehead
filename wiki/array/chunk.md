# `array::chunk`

Chunk array into groups of n

## Usage

```bash
array::chunk size el1 el2 ...
```

**Output:** each chunk on one line, space-separated

## Source

```bash
array::chunk() {
    local size="$1" i=0; shift
    local chunk=""
    for el in "$@"; do
        if [[ -n "$chunk" ]]; then chunk+=" $el"
        else chunk="$el"; fi
        (( i++ ))
        if (( i % size == 0 )); then
            echo "$chunk"
            chunk=""
        fi
    done
    [[ -n "$chunk" ]] && echo "$chunk"
}
```

## Module

[`array`](../array.md)

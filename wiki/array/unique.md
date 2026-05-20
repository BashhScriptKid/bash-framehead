# `array::unique`

Remove duplicate elements (preserves first occurrence order)

## Usage

```bash
array::unique el1 el2 ...
```

## Source

```bash
array::unique() {
    local -A seen=()
    for el in "$@"; do
        if [[ -z "${seen[$el]+x}" ]]; then
            seen["$el"]=1
            echo "$el"
        fi
    done
}
```

## Module

[`array`](../array.md)

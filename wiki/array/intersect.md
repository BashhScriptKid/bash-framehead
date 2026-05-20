# `array::intersect`

Intersection — elements present in both arrays

## Usage

```bash
array::intersect "el1 el2 el3" "el2 el3 el4"
```
Pass each array as a single space-separated string

## Source

```bash
array::intersect() {
    local -a a=($1) b=($2)
    for el in "${a[@]}"; do
        for other in "${b[@]}"; do
            [[ "$el" == "$other" ]] && echo "$el" && break
        done
    done
}
```

## Module

[`array`](../array.md)

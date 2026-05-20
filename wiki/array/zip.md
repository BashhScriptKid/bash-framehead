# `array::zip`

Zip two arrays together — pairs elements by index

## Usage

```bash
array::zip "a1 a2 a3" "b1 b2 b3"
```

**Output:** "a1 b1", "a2 b2", "a3 b3" (one pair per line)

## Source

```bash
array::zip() {
    local -a a=($1) b=($2)
    local len=$(( ${#a[@]} < ${#b[@]} ? ${#a[@]} : ${#b[@]} ))
    local i
    for (( i=0; i<len; i++ )); do
        echo "${a[$i]} ${b[$i]}"
    done
}
```

## Module

[`array`](../array.md)

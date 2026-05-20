# `array::range`

Build a range of integers

## Usage

```bash
array::range start end [step]
```

## Example

```bash
array::range 1 5 → 1 2 3 4 5
```

## Source

```bash
array::range() {
    local start="$1" end="$2" step="${3:-1}"
    local i
    for (( i=start; i<=end; i+=step )); do
        echo "$i"
    done
}
```

## Module

[`array`](../array.md)

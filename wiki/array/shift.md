# `array::shift`

Remove first element

## Usage

```bash
array::shift el1 el2 ...
```

## Source

```bash
array::shift() {
    shift
    printf '%s\n' "$@"
}
```

## Module

[`array`](../array.md)

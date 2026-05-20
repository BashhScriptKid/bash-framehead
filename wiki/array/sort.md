# `array::sort`

Sort elements alphabetically

## Usage

```bash
array::sort el1 el2 ...
```

## Source

```bash
array::sort() {
    printf '%s\n' "$@" | sort
}
```

## Module

[`array`](../array.md)

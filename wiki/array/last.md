# `array::last`

Return last element

## Usage

```bash
array::last el1 el2 ...
```

## Source

```bash
array::last() {
    eval echo "\${$#}"
}
```

## Module

[`array`](../array.md)

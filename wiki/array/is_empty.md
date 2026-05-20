# `array::is_empty`

Check if array is empty

## Usage

```bash
array::is_empty "$@"
```

## Source

```bash
array::is_empty() {
    [[ "$#" -eq 0 ]]
}
```

## Module

[`array`](../array.md)

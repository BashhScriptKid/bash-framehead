# `array::print`

Print each element on its own line (normalise for piping)

## Source

```bash
array::print() {
    printf '%s\n' "$@"
}
```

## Module

[`array`](../array.md)

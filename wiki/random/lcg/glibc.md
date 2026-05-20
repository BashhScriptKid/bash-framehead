# `random::lcg::glibc`

Glibc rand() parameters

## Source

```bash
random::lcg::glibc() {
    _random::mask32 $(( $1 * 1103515245 + 12345 ))
}
```

## Module

[`random`](../random.md)

# `random::lcg`


## Usage

```bash
random::lcg state
```

## Returns

next state (also the output value)

## Source

```bash
random::lcg() {
    _random::mask32 $(( $1 * 1664525 + 1013904223 ))
}
```

## Module

[`random`](../random.md)

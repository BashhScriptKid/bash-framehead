# `random::native::range`

Returns a value in [min, max] inclusive

## Usage

```bash
random::native::range min max
```

## Source

```bash
random::native::range() {
    local min="$1" max="$2"
    echo $(( (RANDOM % (max - min + 1)) + min ))
}
```

## Module

[`random`](../random.md)

# `random::mulberry32`


## Usage

```bash
random::mulberry32 state
```

## Returns

"result new_state"

## Source

```bash
random::mulberry32() {
    local state
    state=$(_random::mask32 $(( $1 + 0x6D2B79F5 )))
    local z="$state"
    z=$(_random::mask32 $(( (z ^ (z >> 15)) * (1 | (z << 1)) )))
    z=$(_random::mask32 $(( z ^ (z >> 7) ^ ( (z ^ (z >> 7)) * (61 | (z << 3)) ) )))
    echo "$(( z ^ (z >> 14) )) $state"
}
```

## Module

[`random`](../random.md)

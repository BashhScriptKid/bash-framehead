# `random::wyrand`


## Usage

```bash
random::wyrand state
```

## Returns

"result new_state"

## Source

```bash
random::wyrand() {
    local state=$(( $1 + 0xa0761d6478bd642f ))
    local a=$(( state ^ 0xe7037ed1a0b428db ))
    # Approximate 128-bit multiply via two halves (best-effort in bash)
    local hi=$(( (state >> 32) * (a >> 32) ))
    local lo=$(( (state & 0xFFFFFFFF) * (a & 0xFFFFFFFF) ))
    local result=$(( hi ^ lo ))
    echo "$result $state"
}
```

## Module

[`random`](../random.md)

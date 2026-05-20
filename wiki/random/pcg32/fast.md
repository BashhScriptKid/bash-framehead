# `random::pcg32::fast`

PCG32 fast — hardcoded increment, same quality

## Usage

```bash
random::pcg32::fast state
```

## Returns

"result new_state"

## Source

```bash
random::pcg32::fast() {
    local state="$1"

    local oldstate="$state"
    state=$(( oldstate * 6364136223846793005 + 1442695040888963407 ))

    local xorshifted=$(( ((oldstate >> 18) ^ oldstate) >> 27 ))
    local rot=$(( oldstate >> 59 ))
    local result
    result=$(_random::mask32 $(( (xorshifted >> rot) | (xorshifted << ((-rot) & 31)) )))

    echo "$result $state"
}
```

## Module

[`random`](../random.md)

# `random::pcg32`


## Usage

```bash
random::pcg32 state inc
```

## Returns

"result new_state"
read -r val state <<< "$(random::pcg32 $state $inc)"

## Source

```bash
random::pcg32() {
    local state="$1" inc="$2"

    local oldstate="$state"
    state=$(( oldstate * 6364136223846793005 + (inc | 1) ))

    local xorshifted=$(( ((oldstate >> 18) ^ oldstate) >> 27 ))
    local rot=$(( oldstate >> 59 ))
    local result
    result=$(_random::mask32 $(( (xorshifted >> rot) | (xorshifted << ((-rot) & 31)) )))

    echo "$result $state"
}
```

## Module

[`random`](../random.md)

# `random::isaac::init`

Initialise simplified ISAAC state

## Usage

```bash
random::isaac::init seed
```

## Returns

"a b c s0 s1 s2 s3 s4 s5 s6 s7"

## Source

```bash
random::isaac::init() {
    local seed="$1" val state
    state="$seed"
    local -a words=()
    for (( i=0; i<8; i++ )); do
        read -r val state <<< "$(random::splitmix64 $state)"
        words+=( "$(_random::mask32 $val)" )
    done
    echo "0 0 0 ${words[*]}"
}
```

## Module

[`random`](../random.md)

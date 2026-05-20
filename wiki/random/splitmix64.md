# `random::splitmix64`


## Usage

```bash
random::splitmix64 state
```

## Returns

"result new_state"
read -r val state <<< "$(random::splitmix64 $state)"

## Source

```bash
random::splitmix64() {
    local state=$(( $1 + 0x9e3779b97f4a7c15 ))
    local z="$state"
    z=$(( (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9 ))
    z=$(( (z ^ (z >> 27)) * 0x94d049bb133111eb ))
    z=$(( z ^ (z >> 31) ))
    echo "$z $state"
}
```

## Module

[`random`](../random.md)

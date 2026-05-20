# `random::xorshiftr128plus`


## Usage

```bash
random::xorshiftr128plus s0 s1
```

## Returns

"result s0_new s1_new"
Caller must unpack and pass s0_new/s1_new on the next call:
  read -r val s0 s1 <<< "$(random::xorshiftr128plus $s0 $s1)"

## Source

```bash
random::xorshiftr128plus() {
    local s0="$1" s1="$2"

    local result=$(( s0 + s1 ))
    s1=$(( s1 ^ s0 ))
    s0=$(( $(_random::rotl64 $s0 23) ^ s1 ^ (s1 << 17) ))
    s1=$(_random::rotl64 $s1 26)

    echo "$result $s0 $s1"
}
```

## Module

[`random`](../random.md)

# `random::xoshiro256ss`


## Usage

```bash
random::xoshiro256ss s0 s1 s2 s3
```

## Returns

"result s0_new s1_new s2_new s3_new"
read -r val s0 s1 s2 s3 <<< "$(random::xoshiro256ss $s0 $s1 $s2 $s3)"

## Source

```bash
random::xoshiro256ss() {
    local s0="$1" s1="$2" s2="$3" s3="$4"

    local result
    result=$(_random::rotl64 $(( s1 * 5 )) 7)
    result=$(( result * 9 ))
    local t=$(( s1 << 17 ))

    s2=$(( s2 ^ s0 ))
    s3=$(( s3 ^ s1 ))
    s1=$(( s1 ^ s2 ))
    s0=$(( s0 ^ s3 ))
    s2=$(( s2 ^ t ))
    s3=$(_random::rotl64 $s3 45)

    echo "$result $s0 $s1 $s2 $s3"
}
```

## Module

[`random`](../random.md)

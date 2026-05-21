# `random::xorshiftr128plus`

**Signature:** `random::xorshiftr128plus(s0, s1)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns: "result s0_new s1_new"

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `s0` | string | Yes | |
| `s1` | string | Yes | |

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


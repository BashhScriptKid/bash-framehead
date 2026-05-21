# `random::pcg32::fast`

**Signature:** `random::pcg32::fast(state)`

**Module:** [`random`](../../random.md) — [Guide](../../guide/index.md)

**Return:** writes to nameref variable (first argument)

## Description

PCG32 fast — hardcoded increment, same quality

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `state` | string | Yes | |

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


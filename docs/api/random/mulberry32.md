# `random::mulberry32`

**Signature:** `random::mulberry32(state)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns: "result new_state"

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `state` | string | Yes | |

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


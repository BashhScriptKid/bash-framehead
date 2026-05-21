# `random::splitmix64`

**Signature:** `random::splitmix64(state)`

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
random::splitmix64() {
    local state=$(( $1 + 0x9e3779b97f4a7c15 ))
    local z="$state"
    z=$(( (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9 ))
    z=$(( (z ^ (z >> 27)) * 0x94d049bb133111eb ))
    z=$(( z ^ (z >> 31) ))
    echo "$z $state"
}
```


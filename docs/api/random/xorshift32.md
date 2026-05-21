# `random::xorshift32`

**Signature:** `random::xorshift32(state)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns: next state (also the output value)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `state` | string | Yes | |

## Source

```bash
random::xorshift32() {
    local x
    x=$(_random::mask32 "$1")
    x=$(( x ^ (x << 13) )); x=$(_random::mask32 $x)
    x=$(( x ^ (x >> 17) ))
    x=$(( x ^ (x << 5)  )); x=$(_random::mask32 $x)
    echo "$x"
}
```


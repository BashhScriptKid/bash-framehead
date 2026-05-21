# `random::middle_square`

**Signature:** `random::middle_square(seed)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns: next value (4-digit middle square extract)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `seed` | string | Yes | |

## Source

```bash
random::middle_square() {
    local x="$1"
    local squared=$(( x * x ))
    echo $(( (squared / 100) % 10000 ))
}
```


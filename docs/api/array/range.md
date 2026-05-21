# `array::range`

**Signature:** `array::range(start, end, [step])`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Build a range of integers

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `start` | string | Yes | |
| `end` | string | Yes | |
| `step` | string | No | |

## Example

```bash
array::range 1 5 → 1 2 3 4 5
```

## Source

```bash
array::range() {
    local start="$1" end="$2" step="${3:-1}"
    local i
    for (( i=start; i<=end; i+=step )); do
        echo "$i"
    done
}
```


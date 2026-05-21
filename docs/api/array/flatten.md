# `array::flatten`

**Signature:** `array::flatten(el1, el2a, el2b, el3)`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Flatten one level — splits each element by whitespace

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `el1` | string | Yes | |
| `el2a` | string | Yes | |
| `el2b` | string | Yes | |
| `el3` | string | Yes | |

## Source

```bash
array::flatten() {
    for el in "$@"; do
        for word in $el; do
            echo "$word"
        done
    done
}
```


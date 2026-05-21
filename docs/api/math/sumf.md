# `math::sumf`

**Signature:** `math::sumf(scale, n1, n2, n3, ...)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Sum of a sequence of floats

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `scale` | string | Yes | |
| `n1` | string | Yes | |
| `n2` | string | Yes | |
| `n3` | string | Yes | |
| `...` | any | — | |

## Source

```bash
math::sumf() {
    local scale=$1; shift
    local total="0"
    for n in "$@"; do total=$(math::bc "$total + $n" "$scale"); done
    echo "$total"
}
```


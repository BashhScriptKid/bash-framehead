# `math::productf`

**Signature:** `math::productf(scale, n1, n2, n3, ...)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Product of a sequence of floats

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
math::productf() {
    local scale=$1; shift
    local result="1"
    for n in "$@"; do result=$(math::bc "$result * $n" "$scale"); done
    echo "$result"
}
```


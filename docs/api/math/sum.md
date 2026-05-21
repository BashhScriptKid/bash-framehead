# `math::sum`

**Signature:** `math::sum(n1, n2, n3, ...)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Sum of a sequence of integers

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `n1` | string | Yes | |
| `n2` | string | Yes | |
| `n3` | string | Yes | |
| `...` | any | — | |

## Source

```bash
math::sum() {
    local total=0
    for n in "$@"; do
        _math::is_float "$n" && { echo "math::sum: float input — use math::sumf" >&2; return 1; }
        (( total += n ))
    done
    echo "$total"
}
```


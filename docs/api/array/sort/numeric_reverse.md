# `array::sort::numeric_reverse`

**Signature:** `array::sort::numeric_reverse()`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Sort elements numerically in reverse


## Source

```bash
array::sort::numeric_reverse() {
    printf '%s\n' "$@" | sort -rn
}
```


# `array::sort::reverse`

**Signature:** `array::sort::reverse()`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Sort elements in reverse


## Source

```bash
array::sort::reverse() {
    printf '%s\n' "$@" | sort -r
}
```


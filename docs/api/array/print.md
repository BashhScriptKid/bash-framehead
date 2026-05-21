# `array::print`

**Signature:** `array::print()`

**Module:** [`array`](../array.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Print each element on its own line (normalise for piping)


## Source

```bash
array::print() {
    printf '%s\n' "$@"
}
```


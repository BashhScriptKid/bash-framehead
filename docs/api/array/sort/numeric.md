# `array::sort::numeric`

**Signature:** `array::sort::numeric()`

**Module:** [`array`](../../array.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

Sort elements numerically


## Source

```bash
array::sort::numeric() {
		printf '%s\n' "$@" | sort -n
}
```


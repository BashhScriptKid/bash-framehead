# `random::seed32`

**Signature:** `random::seed32()`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Seed from /dev/urandom — returns a 32-bit unsigned integer


## Source

```bash
random::seed32() {
		od -An -N4 -tu4 /dev/urandom 2>/dev/null | tr -d ' \n' || echo "$RANDOM"
}
```


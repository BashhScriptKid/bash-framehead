# `random::seed64`

**Signature:** `random::seed64()`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Seed from /dev/urandom — returns a 64-bit value (may be negative in bash)


## Source

```bash
random::seed64() {
		od -An -N8 -tu8 /dev/urandom 2>/dev/null | tr -d ' \n' \
				|| echo "$(( RANDOM * 32768 + RANDOM ))"
}
```


# `random::seed64`

Seed from /dev/urandom — returns a 64-bit value (may be negative in bash)

## Source

```bash
random::seed64() {
    od -An -N8 -tu8 /dev/urandom 2>/dev/null | tr -d ' \n' \
        || echo "$(( RANDOM * 32768 + RANDOM ))"
}
```

## Module

[`random`](../random.md)

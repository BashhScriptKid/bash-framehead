# `random::lcg`

**Signature:** `random::lcg(state)`

**Module:** [`random`](../random.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

LINEAR CONGRUENTIAL GENERATOR (LCG)

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `state` | string | Yes | |

## Source

```bash
random::lcg() {
		_random::mask32 $(( $1 * 1664525 + 1013904223 ))
}
```


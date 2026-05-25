# `random::lcg::glibc`

**Signature:** `random::lcg::glibc(arg1)`

**Module:** [`random`](../../random.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Glibc rand() parameters

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
random::lcg::glibc() {
		_random::mask32 $(( $1 * 1103515245 + 12345 ))
}
```


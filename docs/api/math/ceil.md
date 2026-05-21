# `math::ceil`

**Signature:** `math::ceil(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

Ceiling — smallest integer ≥ n

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::ceil() {
  local n
  if [[ ! -t 0 ]]; then n=$(cat); else n="$1"; fi
    math::bc "scale=0; if ($n == ($n / 1)) $n else if ($n > 0) ($n / 1) + 1 else ($n / 1)"
}
```


# `math::floor`

**Signature:** `math::floor(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- FLOATING POINT (requires bc) ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::floor() {
	local n
	if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
		math::bc "scale=0; $n / 1"
}
```


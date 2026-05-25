# `math::is_int`

**Signature:** `math::is_int(arg1)`

**Module:** [`math`](../math.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
math::is_int() {
	local n
	if [[ $# -ge 1 ]]; then n="$1"; else n=$(cat); fi
		[[ "$n" =~ ^-?[0-9]+$ ]]
}
```


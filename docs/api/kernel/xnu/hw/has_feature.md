# `kernel::xnu::hw::has_feature`

**Signature:** `kernel::xnu::hw::has_feature(arg1)`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::xnu::hw::has_feature() {
	local _feature="$1"
	sysctl -n "hw.optional.${_feature}" 2>/dev/null || echo "0"
}
```


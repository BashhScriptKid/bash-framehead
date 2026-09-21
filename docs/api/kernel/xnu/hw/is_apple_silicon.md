# `kernel::xnu::hw::is_apple_silicon`

**Signature:** `kernel::xnu::hw::is_apple_silicon()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::xnu::hw::is_apple_silicon() {
	local _val
	_val=$(sysctl -n hw.optional.arm64 2>/dev/null) || { echo "0"; return 1; }
	echo "$_val"
}
```


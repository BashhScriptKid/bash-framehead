# `kernel::mm::lru_gen::status`

**Signature:** `kernel::mm::lru_gen::status()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::mm::lru_gen::status() {
	local _enabled _ttl
	_enabled=$(cat /sys/kernel/mm/lru_gen/enabled 2>/dev/null) || { echo "unknown"; return 1; }
	_ttl=$(cat /sys/kernel/mm/lru_gen/min_ttl_ms 2>/dev/null) || _ttl="unknown"
	printf 'enabled=%s ttl_ms=%s\n' "$_enabled" "$_ttl"
}
```


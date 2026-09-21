# `kernel::vm::vfs_cache_pressure::get`

**Signature:** `kernel::vm::vfs_cache_pressure::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::vfs_cache_pressure::get() {
	cat /proc/sys/vm/vfs_cache_pressure 2>/dev/null || echo "unknown"
}
```


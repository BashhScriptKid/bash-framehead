# `kernel::vm::admin_reserve::get`

**Signature:** `kernel::vm::admin_reserve::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::admin_reserve::get() {
	cat /proc/sys/vm/admin_reserve_kbytes 2>/dev/null || echo "unknown"
}
```


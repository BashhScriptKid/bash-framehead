# `kernel::vm::dirty_writeback::get`

**Signature:** `kernel::vm::dirty_writeback::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::dirty_writeback::get() {
	cat /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null || echo "unknown"
}
```


# `kernel::vm::min_free::get`

**Signature:** `kernel::vm::min_free::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::min_free::get() {
	cat /proc/sys/vm/min_free_kbytes 2>/dev/null || echo "unknown"
}
```


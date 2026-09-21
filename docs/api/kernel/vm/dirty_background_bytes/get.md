# `kernel::vm::dirty_background_bytes::get`

**Signature:** `kernel::vm::dirty_background_bytes::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::dirty_background_bytes::get() {
	cat /proc/sys/vm/dirty_background_bytes 2>/dev/null || echo "unknown"
}
```


# `kernel::vm::dirty_background_ratio::get`

**Signature:** `kernel::vm::dirty_background_ratio::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::dirty_background_ratio::get() {
	cat /proc/sys/vm/dirty_background_ratio 2>/dev/null || echo "unknown"
}
```


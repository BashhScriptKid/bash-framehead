# `kernel::vm::extfrag_threshold::get`

**Signature:** `kernel::vm::extfrag_threshold::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::extfrag_threshold::get() {
	cat /proc/sys/vm/extfrag_threshold 2>/dev/null || echo "unknown"
}
```


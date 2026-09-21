# `kernel::vm::legacy_va_layout::get`

**Signature:** `kernel::vm::legacy_va_layout::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::legacy_va_layout::get() {
	cat /proc/sys/vm/legacy_va_layout 2>/dev/null || echo "unknown"
}
```


# `kernel::vm::soft_offline::get`

**Signature:** `kernel::vm::soft_offline::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::soft_offline::get() {
	cat /proc/sys/vm/enable_soft_offline 2>/dev/null || echo "unknown"
}
```


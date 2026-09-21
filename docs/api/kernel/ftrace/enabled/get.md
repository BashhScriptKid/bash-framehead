# `kernel::ftrace::enabled::get`

**Signature:** `kernel::ftrace::enabled::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::ftrace::enabled::get() {
	cat /proc/sys/kernel/ftrace_enabled 2>/dev/null || echo "unknown"
}
```


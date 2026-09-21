# `kernel::coredump::uses_pid::get`

**Signature:** `kernel::coredump::uses_pid::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::coredump::uses_pid::get() {
	cat /proc/sys/kernel/core_uses_pid 2>/dev/null || echo "unknown"
}
```


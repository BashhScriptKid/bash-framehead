# `kernel::vm::memory_failure::early_kill::get`

**Signature:** `kernel::vm::memory_failure::early_kill::get()`

**Module:** [`kernel`](../../../../kernel.md) — [Guide](../../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::vm::memory_failure::early_kill::get() {
	cat /proc/sys/vm/memory_failure_early_kill 2>/dev/null || echo "unknown"
}
```


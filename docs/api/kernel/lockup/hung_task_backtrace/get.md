# `kernel::lockup::hung_task_backtrace::get`

**Signature:** `kernel::lockup::hung_task_backtrace::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::lockup::hung_task_backtrace::get() {
	cat /proc/sys/kernel/hung_task_all_cpu_backtrace 2>/dev/null || echo "unknown"
}
```


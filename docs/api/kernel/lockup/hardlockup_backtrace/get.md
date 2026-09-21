# `kernel::lockup::hardlockup_backtrace::get`

**Signature:** `kernel::lockup::hardlockup_backtrace::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::lockup::hardlockup_backtrace::get() {
	cat /proc/sys/kernel/hardlockup_all_cpu_backtrace 2>/dev/null || echo "unknown"
}
```


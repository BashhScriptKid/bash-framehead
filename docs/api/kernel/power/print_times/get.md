# `kernel::power::print_times::get`

**Signature:** `kernel::power::print_times::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::print_times::get() {
	cat /sys/power/pm_print_times 2>/dev/null || echo "unknown"
}
```


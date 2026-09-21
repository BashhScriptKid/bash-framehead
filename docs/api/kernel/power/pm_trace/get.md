# `kernel::power::pm_trace::get`

**Signature:** `kernel::power::pm_trace::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::pm_trace::get() {
	cat /sys/power/pm_trace 2>/dev/null || echo "unknown"
}
```


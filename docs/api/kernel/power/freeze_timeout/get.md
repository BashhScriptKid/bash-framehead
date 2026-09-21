# `kernel::power::freeze_timeout::get`

**Signature:** `kernel::power::freeze_timeout::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::freeze_timeout::get() {
	cat /sys/power/pm_freeze_timeout 2>/dev/null || echo "unknown"
}
```


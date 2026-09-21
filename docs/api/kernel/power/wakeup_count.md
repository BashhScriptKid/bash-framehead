# `kernel::power::wakeup_count`

**Signature:** `kernel::power::wakeup_count()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::wakeup_count() {
	cat /sys/power/wakeup_count 2>/dev/null || echo "unknown"
}
```


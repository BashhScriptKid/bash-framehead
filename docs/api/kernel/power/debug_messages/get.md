# `kernel::power::debug_messages::get`

**Signature:** `kernel::power::debug_messages::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::debug_messages::get() {
	cat /sys/power/pm_debug_messages 2>/dev/null || echo "unknown"
}
```


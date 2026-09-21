# `kernel::power::sync_on_suspend::get`

**Signature:** `kernel::power::sync_on_suspend::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::sync_on_suspend::get() {
	cat /sys/power/sync_on_suspend 2>/dev/null || echo "unknown"
}
```


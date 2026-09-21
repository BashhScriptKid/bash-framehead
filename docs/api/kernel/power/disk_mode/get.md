# `kernel::power::disk_mode::get`

**Signature:** `kernel::power::disk_mode::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::disk_mode::get() {
	cat /sys/power/disk 2>/dev/null || echo "unknown"
}
```


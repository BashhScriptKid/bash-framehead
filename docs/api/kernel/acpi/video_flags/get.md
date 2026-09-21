# `kernel::acpi::video_flags::get`

**Signature:** `kernel::acpi::video_flags::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::acpi::video_flags::get() {
	cat /proc/sys/kernel/acpi_video_flags 2>/dev/null || echo "unknown"
}
```


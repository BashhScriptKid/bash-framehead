# `kernel::power::freeze_filesystems::get`

**Signature:** `kernel::power::freeze_filesystems::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::freeze_filesystems::get() {
	cat /sys/power/freeze_filesystems 2>/dev/null || echo "unknown"
}
```


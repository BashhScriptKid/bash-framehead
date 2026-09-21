# `kernel::power::resume_offset::get`

**Signature:** `kernel::power::resume_offset::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::resume_offset::get() {
	cat /sys/power/resume_offset 2>/dev/null || echo "unknown"
}
```


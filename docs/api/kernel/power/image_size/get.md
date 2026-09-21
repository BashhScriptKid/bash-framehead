# `kernel::power::image_size::get`

**Signature:** `kernel::power::image_size::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::image_size::get() {
	cat /sys/power/image_size 2>/dev/null || echo "unknown"
}
```


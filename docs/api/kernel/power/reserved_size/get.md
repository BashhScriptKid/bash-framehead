# `kernel::power::reserved_size::get`

**Signature:** `kernel::power::reserved_size::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::reserved_size::get() {
	cat /sys/power/reserved_size 2>/dev/null || echo "unknown"
}
```


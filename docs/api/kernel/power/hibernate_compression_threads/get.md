# `kernel::power::hibernate_compression_threads::get`

**Signature:** `kernel::power::hibernate_compression_threads::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::hibernate_compression_threads::get() {
	cat /sys/power/hibernate_compression_threads 2>/dev/null || echo "unknown"
}
```


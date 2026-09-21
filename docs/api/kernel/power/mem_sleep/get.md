# `kernel::power::mem_sleep::get`

**Signature:** `kernel::power::mem_sleep::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::power::mem_sleep::get() {
	cat /sys/power/mem_sleep 2>/dev/null || echo "unknown"
}
```


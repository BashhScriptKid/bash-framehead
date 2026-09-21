# `kernel::security::perf_paranoid::get`

**Signature:** `kernel::security::perf_paranoid::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::security::perf_paranoid::get() {
	cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null || echo "unknown"
}
```


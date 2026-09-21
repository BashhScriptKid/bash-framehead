# `kernel::coredump::pattern::get`

**Signature:** `kernel::coredump::pattern::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::coredump::pattern::get() {
	cat /proc/sys/kernel/core_pattern 2>/dev/null || echo "unknown"
}
```


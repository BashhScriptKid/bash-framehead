# `kernel::security::dmesg_restrict::get`

**Signature:** `kernel::security::dmesg_restrict::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::security::dmesg_restrict::get() {
	cat /proc/sys/kernel/dmesg_restrict 2>/dev/null || echo "unknown"
}
```


# `kernel::reboot::mode`

**Signature:** `kernel::reboot::mode()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::reboot::mode() {
	cat /sys/kernel/reboot/mode 2>/dev/null || echo "unknown"
}
```


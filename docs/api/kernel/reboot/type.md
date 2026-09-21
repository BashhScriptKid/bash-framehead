# `kernel::reboot::type`

**Signature:** `kernel::reboot::type()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::reboot::type() {
	cat /sys/kernel/reboot/type 2>/dev/null || echo "unknown"
}
```


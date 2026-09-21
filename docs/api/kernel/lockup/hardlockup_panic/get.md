# `kernel::lockup::hardlockup_panic::get`

**Signature:** `kernel::lockup::hardlockup_panic::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::lockup::hardlockup_panic::get() {
	cat /proc/sys/kernel/hardlockup_panic 2>/dev/null || echo "unknown"
}
```


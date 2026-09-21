# `kernel::panic::on_oops::get`

**Signature:** `kernel::panic::on_oops::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::panic::on_oops::get() {
	cat /proc/sys/kernel/panic_on_oops 2>/dev/null || echo "unknown"
}
```


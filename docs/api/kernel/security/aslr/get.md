# `kernel::security::aslr::get`

**Signature:** `kernel::security::aslr::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::security::aslr::get() {
	cat /proc/sys/kernel/randomize_va_space 2>/dev/null || echo "unknown"
}
```


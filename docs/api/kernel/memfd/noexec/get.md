# `kernel::memfd::noexec::get`

**Signature:** `kernel::memfd::noexec::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::memfd::noexec::get() {
	cat /proc/sys/vm/memfd_noexec 2>/dev/null || echo "unknown"
}
```


# `kernel::domainname::get`

**Signature:** `kernel::domainname::get()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::domainname::get() {
	cat /proc/sys/kernel/domainname 2>/dev/null || echo "unknown"
}
```


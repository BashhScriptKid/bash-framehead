# `kernel::acct::interval::get`

**Signature:** `kernel::acct::interval::get()`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::acct::interval::get() {
	cat /proc/sys/kernel/acct 2>/dev/null || echo "unknown"
}
```


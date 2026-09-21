# `kernel::syslog::last`

**Signature:** `kernel::syslog::last()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::syslog::last() {
	local _count="${1:-50}"
	dmesg 2>/dev/null | tail -"$_count"
}
```


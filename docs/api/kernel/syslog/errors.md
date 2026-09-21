# `kernel::syslog::errors`

**Signature:** `kernel::syslog::errors()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::syslog::errors() {
	dmesg --level=err,crit,alert,emerg 2>/dev/null || \
		dmesg 2>/dev/null | grep -iE 'err|crit|alert|emerg'
}
```


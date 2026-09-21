# `kernel::syslog::read`

**Signature:** `kernel::syslog::read()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- SYSLOG ---


## Source

```bash
kernel::syslog::read() {
	local _level="${1:-}"
	if [[ -n "$_level" ]]; then
		dmesg --level="$_level" 2>/dev/null || dmesg 2>/dev/null
	else
		dmesg 2>/dev/null
	fi
}
```


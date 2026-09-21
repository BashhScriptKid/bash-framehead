# `kernel::syslog::level`

**Signature:** `kernel::syslog::level(arg1, arg2, arg3, arg4)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |
| `arg4` | string | Yes | |

## Source

```bash
kernel::syslog::level() {
	awk '{print $1, $2, $3, $4}' /proc/sys/kernel/printk 2>/dev/null || echo "unknown"
}
```


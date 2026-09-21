# `kernel::syslog::since`

**Signature:** `kernel::syslog::since(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::syslog::since() {
	local _time="$1"
	[[ -z "$_time" ]] && { kernel::syslog::last; return; }
	dmesg -T 2>/dev/null | awk -v t="$_time" '$0>=t' || dmesg 2>/dev/null
}
```


# `kernel::load::avg`

**Signature:** `kernel::load::avg(arg1, arg2, arg3)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

--- LOAD / UPTIME ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
kernel::load::avg() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '{print $1, $2, $3}' /proc/loadavg 2>/dev/null
		;;
	darwin|freebsd|openbsd|netbsd)
		sysctl -n vm.loadavg 2>/dev/null | awk '{print $1, $2, $3}'
		;;
	*)
		uptime 2>/dev/null | awk -F'load average[s]?: ' '{print $2}'
		;;
	esac
}
```


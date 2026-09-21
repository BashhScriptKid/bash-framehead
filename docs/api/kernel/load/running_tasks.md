# `kernel::load::running_tasks`

**Signature:** `kernel::load::running_tasks(arg4)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg4` | string | Yes | |

## Source

```bash
kernel::load::running_tasks() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '{print $4}' /proc/loadavg 2>/dev/null
		;;
	darwin|freebsd|openbsd|netbsd)
		sysctl -n vm.loadavg 2>/dev/null | awk '{print $4}'
		;;
	*)
		echo "unknown"
		;;
	esac
}
```


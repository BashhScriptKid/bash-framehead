# `kernel::sysctl::list`

**Signature:** `kernel::sysctl::list(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::sysctl::list() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		find /proc/sys -type f 2>/dev/null | sed 's|^/proc/sys/||;s|/|.|g'
		;;
	freebsd|netbsd|openbsd|darwin)
		sysctl -a 2>/dev/null | awk -F': ' '{print $1}'
		;;
	*)
		echo "unknown"
		;;
	esac
}
```


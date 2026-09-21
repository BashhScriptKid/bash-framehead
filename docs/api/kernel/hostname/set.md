# `kernel::hostname::set`

**Signature:** `kernel::hostname::set(arg1)`

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
kernel::hostname::set() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		runtime::is_root || { echo "kernel::hostname::set: requires root" >&2; return 1; }
		echo "$1" > /proc/sys/kernel/hostname
		;;
	darwin)
		runtime::is_root || { echo "kernel::hostname::set: requires root" >&2; return 1; }
		scutil --set ComputerName "$1" 2>/dev/null || return 1
		;;
	freebsd|openbsd|netbsd)
		runtime::is_root || { echo "kernel::hostname::set: requires root" >&2; return 1; }
		sysctl kern.hostname="$1" 2>/dev/null || return 1
		;;
	*)
		hostname "$1" 2>/dev/null || return 1
		;;
	esac
}
```


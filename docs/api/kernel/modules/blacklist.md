# `kernel::modules::blacklist`

**Signature:** `kernel::modules::blacklist(arg1)`

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
kernel::modules::blacklist() {
	local _module="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::modules::blacklist: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		echo "blacklist $_module" >> /etc/modprobe.d/blacklist.conf 2>/dev/null || return 1
		;;
	freebsd)
		echo "module_blacklist $_module" >> /boot/loader.conf 2>/dev/null || return 1
		;;
	netbsd|openbsd)
		echo "module $_module disabled" >> /etc/rc.conf 2>/dev/null || return 1
		;;
	darwin)
		echo "kernel::modules::blacklist: unsupported on macOS" >&2
		return 1
		;;
	*)
		echo "kernel::modules::blacklist: unsupported OS" >&2
		return 1
		;;
	esac
}
```


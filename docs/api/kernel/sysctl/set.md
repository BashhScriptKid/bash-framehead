# `kernel::sysctl::set`

**Signature:** `kernel::sysctl::set(arg1, arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
kernel::sysctl::set() {
	local _key="$1" _value="$2" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::sysctl::set: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		echo "$_value" > "/proc/sys/${_key//./\/}" 2>/dev/null
		;;
	freebsd|netbsd|openbsd|darwin)
		sysctl "${_key}=${_value}" 2>/dev/null
		;;
	*)
		echo "kernel::sysctl::set: unsupported OS" >&2
		return 1
		;;
	esac
}
```


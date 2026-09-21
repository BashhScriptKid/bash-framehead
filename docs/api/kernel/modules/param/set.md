# `kernel::modules::param::set`

**Signature:** `kernel::modules::param::set(arg1, arg2, arg3)`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

## Source

```bash
kernel::modules::param::set() {
	local _module="$1" _param="$2" _value="$3" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::modules::param::set: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		echo "$_value" > "/sys/module/${_module}/parameters/${_param}"
		;;
	freebsd|netbsd|openbsd)
		sysctl "${_module}.${_param}=${_value}" 2>/dev/null
		;;
	darwin)
		echo "kernel::modules::param::set: unsupported on macOS" >&2
		return 1
		;;
	*)
		echo "kernel::modules::param::set: unsupported OS" >&2
		return 1
		;;
	esac
}
```


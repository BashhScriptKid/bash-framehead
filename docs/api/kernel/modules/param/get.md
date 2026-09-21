# `kernel::modules::param::get`

**Signature:** `kernel::modules::param::get(arg1, arg2)`

**Module:** [`kernel`](../../../kernel.md) — [Guide](../../../guide/index.md)

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
kernel::modules::param::get() {
	local _module="$1" _param="$2" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		cat "/sys/module/${_module}/parameters/${_param}" 2>/dev/null || echo "unknown"
		;;
	freebsd|netbsd|openbsd)
		sysctl -n "${_module}.${_param}" 2>/dev/null || echo "unknown"
		;;
	darwin)
		echo "unsupported"
		;;
	*)
		echo "unknown"
		;;
	esac
}
```


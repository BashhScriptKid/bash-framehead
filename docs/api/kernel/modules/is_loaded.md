# `kernel::modules::is_loaded`

**Signature:** `kernel::modules::is_loaded(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::modules::is_loaded() {
	local _module="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		grep -q "^${_module} " /proc/modules 2>/dev/null
		;;
	darwin)
		kextstat 2>/dev/null | grep -q "$_module"
		;;
	freebsd|openbsd|netbsd)
		kldstat 2>/dev/null | grep -q "$_module"
		;;
	*)
		return 1
		;;
	esac
}
```


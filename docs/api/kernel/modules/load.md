# `kernel::modules::load`

**Signature:** `kernel::modules::load(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- MODULE LOADING ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::modules::load() {
	local _module="$1" _params="${2:-}" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::modules::load: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		if runtime::has_command modprobe; then
			modprobe "$_module" $_params 2>/dev/null
		elif runtime::has_command insmod; then
			local _path
			_path=$(modinfo -n "$_module" 2>/dev/null) || _path="$_module"
			insmod "$_path" $_params 2>/dev/null
		else
			echo "kernel::modules::load: modprobe/insmod not found" >&2
			return 1
		fi
		;;
	freebsd|dragonfly)
		kldload "$_module" 2>/dev/null
		;;
	netbsd|openbsd)
		modload "$_module" 2>/dev/null
		;;
	darwin)
		kextload "$_module" 2>/dev/null
		;;
	*)
		echo "kernel::modules::load: unsupported OS" >&2
		return 1
		;;
	esac
}
```


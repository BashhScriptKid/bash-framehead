# `kernel::modules::unload`

**Signature:** `kernel::modules::unload(arg1)`

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
kernel::modules::unload() {
	local _module="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	runtime::is_root || { echo "kernel::modules::unload: requires root" >&2; return 1; }
	case "$_os" in
	linux)
		if runtime::has_command modprobe; then
			modprobe -r "$_module" 2>/dev/null
		elif runtime::has_command rmmod; then
			rmmod "$_module" 2>/dev/null
		else
			echo "kernel::modules::unload: modprobe/rmmod not found" >&2
			return 1
		fi
		;;
	freebsd|dragonfly)
		kldunload "$_module" 2>/dev/null
		;;
	netbsd|openbsd)
		modunload "$_module" 2>/dev/null
		;;
	darwin)
		kextunload "$_module" 2>/dev/null
		;;
	*)
		echo "kernel::modules::unload: unsupported OS" >&2
		return 1
		;;
	esac
}
```


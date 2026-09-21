# `kernel::modules::list`

**Signature:** `kernel::modules::list(arg1, arg2, arg3, arg4)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- MODULES ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |
| `arg4` | string | Yes | |

## Source

```bash
kernel::modules::list() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '{printf "%s %s %s\n", $1, $2, $3}' /proc/modules 2>/dev/null
		;;
	darwin)
		kextstat 2>/dev/null | awk 'NR>1{printf "%s %s %s\n", $2, $3, $4}'
		;;
	freebsd|openbsd|netbsd)
		kldstat 2>/dev/null | awk 'NR>1{printf "%s %s %s\n", $2, $3, $4}'
		;;
	*)
		echo "unknown"
		;;
	esac
}
```


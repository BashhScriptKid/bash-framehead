# `kernel::sysctl::get`

**Signature:** `kernel::sysctl::get(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- SYSCTL (cross-platform) ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::sysctl::get() {
	local _key="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		if [[ -f "/proc/sys/${_key//./\/}" ]]; then
			cat "/proc/sys/${_key//./\/}" 2>/dev/null || echo "unknown"
		else
			echo "unknown"
			return 1
		fi
		;;
	freebsd|netbsd|openbsd|darwin)
		sysctl -n "$_key" 2>/dev/null || echo "unknown"
		;;
	*)
		echo "unknown"
		;;
	esac
}
```


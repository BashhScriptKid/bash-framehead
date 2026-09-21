# `kernel::sysctl::exists`

**Signature:** `kernel::sysctl::exists(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::sysctl::exists() {
	local _key="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		[[ -f "/proc/sys/${_key//./\/}" ]]
		;;
	freebsd|netbsd|openbsd|darwin)
		sysctl -n "$_key" >/dev/null 2>&1
		;;
	*)
		return 1
		;;
	esac
}
```


# `kernel::version::full`

**Signature:** `kernel::version::full()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::version::full() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		cat /proc/version 2>/dev/null || uname -v
		;;
	*)
		uname -v 2>/dev/null || echo "unknown"
		;;
	esac
}
```


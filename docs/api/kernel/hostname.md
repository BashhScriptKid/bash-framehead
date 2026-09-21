# `kernel::hostname`

**Signature:** `kernel::hostname()`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::hostname() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		cat /proc/sys/kernel/hostname 2>/dev/null || hostname
		;;
	darwin|freebsd|openbsd|netbsd)
		sysctl -n kern.hostname 2>/dev/null || hostname
		;;
	*)
		hostname 2>/dev/null || echo "unknown"
		;;
	esac
}
```


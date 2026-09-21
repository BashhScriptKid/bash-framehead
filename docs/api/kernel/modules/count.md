# `kernel::modules::count`

**Signature:** `kernel::modules::count()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
kernel::modules::count() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		wc -l < /proc/modules 2>/dev/null
		;;
	darwin)
		kextstat 2>/dev/null | awk 'NR>1' | wc -l
		;;
	freebsd|openbsd|netbsd)
		kldstat 2>/dev/null | awk 'NR>1' | wc -l
		;;
	*)
		echo "0"
		;;
	esac
}
```


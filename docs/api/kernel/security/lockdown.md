# `kernel::security::lockdown`

**Signature:** `kernel::security::lockdown()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- SECURITY ---


## Source

```bash
kernel::security::lockdown() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		if [[ -f /sys/kernel/security/lockdown ]]; then
			cat /sys/kernel/security/lockdown 2>/dev/null
		else
			echo "[none]"
		fi
		;;
	darwin)
		local _sip
		_sip=$(csrutil status 2>&1)
		if [[ "$_sip" == *"enabled"* ]]; then
			echo "sip=enabled"
		else
			echo "sip=disabled"
		fi
		;;
	freebsd|openbsd|netbsd)
		local _level
		_level=$(sysctl -n kern.securelevel 2>/dev/null) || _level="-1"
		echo "securelevel=$_level"
		;;
	*)
		echo "unsupported"
		;;
	esac
}
```


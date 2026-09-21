# `kernel::security::is_locked`

**Signature:** `kernel::security::is_locked()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._


## Source

```bash
kernel::security::is_locked() {
	local _os _mode
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		_mode=$(cat /sys/kernel/security/lockdown 2>/dev/null) || return 1
		[[ "$_mode" != *"none"* ]]
		;;
	darwin)
		local _sip
		_sip=$(csrutil status 2>&1)
		[[ "$_sip" == *"enabled"* ]]
		;;
	freebsd|openbsd|netbsd)
		local _level
		_level=$(sysctl -n kern.securelevel 2>/dev/null) || _level="-1"
		(( _level > 0 ))
		;;
	*)
		return 1
		;;
	esac
}
```


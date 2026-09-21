# `kernel::sysrq::enabled`

**Signature:** `kernel::sysrq::enabled()`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

--- SYSRQ ---


## Source

```bash
kernel::sysrq::enabled() {
	local _val
	_val=$(cat /proc/sys/kernel/sysrq 2>/dev/null) || { echo "unknown"; return 1; }
	if [[ "$_val" == "1" ]]; then
		echo "enabled (all)"
	elif [[ "$_val" == "0" ]]; then
		echo "disabled"
	else
		local _flags=""
		(( _val & 1 )) && _flags="${_flags}r(read) "
		(( _val & 2 )) && _flags="${_flags}k(SAK) "
		(( _val & 4 )) && _flags="${_flags}b(reboot) "
		(( _val & 8 )) && _flags="${_flags}o(poweroff) "
		(( _val & 16 )) && _flags="${_flags}s(sync) "
		(( _val & 32 )) && _flags="${_flags}t(tasks) "
		(( _val & 64 )) && _flags="${_flags}m(mount) "
		(( _val & 128 )) && _flags="${_flags}n(nice) "
		(( _val & 256 )) && _flags="${_flags}p(dump) "
		(( _val & 512 )) && _flags="${_flags}u(unicode) "
		(( _val & 1024 )) && _flags="${_flags}v(vt) "
		printf 'partial (%s) mask=%s\n' "${_flags% }" "$_val"
	fi
}
```


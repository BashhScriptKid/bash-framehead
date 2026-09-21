# `kernel::uptime`

**Signature:** `kernel::uptime(arg1, arg4)`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg4` | string | Yes | |

## Source

```bash
kernel::uptime() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		awk '{printf "%.0f", $1}' /proc/uptime 2>/dev/null
		;;
	darwin)
		local _boot _now
		_boot=$(sysctl -n kern.boottime 2>/dev/null | awk '{print $4}' | tr -d ',')
		_now=$(date +%s)
		[[ -n "$_boot" && -n "$_now" ]] && echo $((_now - _boot))
		;;
	freebsd|openbsd|netbsd)
		local _boot _now
		_boot=$(sysctl -n kern.boottime 2>/dev/null | awk -F'[= ]+' '{for(i=1;i<=NF;i++)if($i~/^[0-9]+$/){print $i;exit}}')
		_now=$(date +%s)
		[[ -n "$_boot" && -n "$_now" ]] && echo $((_now - _boot))
		;;
	*)
		local _boot_ts _now_ts
		_boot_ts=$(uptime -s 2>/dev/null | xargs -I{} date -d {} +%s 2>/dev/null) || return 1
		_now_ts=$(date +%s)
		echo $((_now_ts - _boot_ts))
		;;
	esac
}
```


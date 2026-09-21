# `runtime::sysinit`

**Signature:** `runtime::sysinit()`

**Module:** [`runtime`](../runtime.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
runtime::sysinit() {
	local _pid1
	_pid1=$(ps -p 1 -o comm= 2>/dev/null) || _pid1="unknown"

	case "$_pid1" in
	systemd)
		echo "systemd"
		;;
	init)
		# SysVinit or Upstart — check further
		if [[ -d /run/systemd/system ]]; then
			echo "systemd"
		elif [[ -d /run/openrc ]]; then
			echo "openrc"
		elif [[ -d /run/runit ]]; then
			echo "runit"
		elif [[ -d /run/s6 ]]; then
			echo "s6"
		elif [[ -f /sbin/upstart ]]; then
			echo "upstart"
		else
			echo "sysvinit"
		fi
		;;
	launchd)
		echo "launchd"
		;;
	runit)
		echo "runit"
		;;
	s6-svscan)
		echo "s6"
		;;
	OpenRC)
		echo "openrc"
		;;
	daemon)
		echo "rc"
		;;
	svc)
		echo "runit"
		;;
	*)
		echo "$_pid1"
		;;
	esac
}
```


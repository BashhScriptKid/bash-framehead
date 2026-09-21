# `kernel::load::is_heavy`

**Signature:** `kernel::load::is_heavy(arg1, arg2)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** exit code — 0 (true) or 1 (false)

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
kernel::load::is_heavy() {
	local _load _nproc _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		_load=$(awk '{print $1}' /proc/loadavg 2>/dev/null) || return 1
		_nproc=$(nproc 2>/dev/null) || _nproc=$(getconf _NPROCESSORS_ONLN 2>/dev/null) || _nproc=1
		awk "BEGIN{exit !($_load > $_nproc)}" 2>/dev/null
		;;
	darwin|freebsd|openbsd|netbsd)
		_load=$(sysctl -n vm.loadavg 2>/dev/null | awk '{print $1}') || return 1
		_nproc=$(sysctl -n hw.ncpu 2>/dev/null) || _nproc=1
		awk "BEGIN{exit !($_load > $_nproc)}" 2>/dev/null
		;;
	*)
		_load=$(uptime 2>/dev/null | awk -F'load average[s]?: ' '{print $2}' | awk -F, '{print $1}') || return 1
		_nproc=$(getconf _NPROCESSORS_ONLN 2>/dev/null) || _nproc=1
		awk "BEGIN{exit !($_load > $_nproc)}" 2>/dev/null
		;;
	esac
}
```


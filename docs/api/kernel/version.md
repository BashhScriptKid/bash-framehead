# `kernel::version`

**Signature:** `kernel::version()`

**Module:** [`kernel`](../kernel.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

!/usr/bin/env bash


## Source

```bash
kernel::version() {
	local _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		if [[ -f /proc/version ]]; then
			local _ver
			_ver=$(uname -r)
			printf '%s' "${_ver%%-*}"
		else
			uname -r
		fi
		;;
	darwin)
		uname -r
		;;
	*)
		return 1
		;;
	esac
}
```


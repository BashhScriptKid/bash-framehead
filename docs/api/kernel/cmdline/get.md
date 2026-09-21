# `kernel::cmdline::get`

**Signature:** `kernel::cmdline::get(arg1)`

**Module:** [`kernel`](../../kernel.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |

## Source

```bash
kernel::cmdline::get() {
	local _key="$1"
	local _cmdline
	_cmdline=$(cat /proc/cmdline 2>/dev/null) || return 1
	local _pair
	for _pair in $_cmdline; do
		case "$_pair" in
		${_key}=*)
			printf '%s' "${_pair#*=}"
			return 0
			;;
		${_key})
			echo "1"
			return 0
			;;
		esac
	done
	return 1
}
```


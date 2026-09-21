# `kernel::modules::params`

**Signature:** `kernel::modules::params(arg1)`

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
kernel::modules::params() {
	local _module="$1" _os
	_os=$(runtime::os 2>/dev/null) || _os="linux"
	case "$_os" in
	linux)
		local _dir="/sys/module/${_module}/parameters"
		[[ -d "$_dir" ]] || { echo "unknown"; return 1; }
		local _file _val
		for _file in "$_dir"/*; do
			[[ -f "$_file" ]] || continue
			_val=$(cat "$_file" 2>/dev/null) || continue
			printf '%s=%s\n' "$(basename "$_file")" "$_val"
		done
		;;
	freebsd|netbsd|openbsd)
		sysctl -a 2>/dev/null | grep "^${_module}\." || echo "unknown"
		;;
	darwin)
		echo "unsupported"
		;;
	*)
		echo "unknown"
		;;
	esac
}
```


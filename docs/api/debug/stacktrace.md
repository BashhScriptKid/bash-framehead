# `debug::stacktrace`

**Signature:** `debug::stacktrace([autocolour|colour|mono])`

**Module:** [`debug`](../debug.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- STACKTRACE ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `autocolour|colour|mono` | string | No | |

## Source

```bash
debug::stacktrace() {
		local _colour_mode="${1:-autocolour}"
		case "$_colour_mode" in
				colour|mono|autocolour) ;;
				*) _colour_mode='autocolour' ;;
		esac

		_debug::resolve_colour "$_colour_mode" && local _colour_enabled=1 || local _colour_enabled=0
		_debug::colour_vars "$_colour_enabled"

		local _i=0 _file _func _line

		echo
		echo 'Stack trace'
		while true; do
				_file=${BASH_SOURCE[_i+1]}
				_func=${FUNCNAME[_i]}
				_line=${BASH_LINENO[_i]}
				[[ -n "$_file" ]] || break

				printf '    at `%s` %s(%s:%s)%s\n' \
						"$_func" \
						"$_dc_cyan" \
						"$_file" \
						"$_line" \
						"$_dc_rst"

				((_i++))
		done
		echo

		return 0
}
```


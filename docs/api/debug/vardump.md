# `debug::vardump`

**Signature:** `debug::vardump(<varname>, [autocolour|colour|mono], [verbose])`

**Module:** [`debug`](../debug.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

--- VARDUMP ---

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `<varname>` | variable | Yes | |
| `autocolour|colour|mono` | string | No | |
| `verbose` | string | No | |

## Source

```bash
debug::vardump() {
		local _name="$1"; shift || true
		if [[ -z "$_name" ]]; then
				echo "debug::vardump: name required as first argument" >&2
				return 1
		fi

		# Parse remaining positional args
		local _verbose=false _colour_mode='autocolour'
		local _arg
		for _arg in "$@"; do
				case "$_arg" in
						verbose)                    _verbose=true ;;
						colour|mono|autocolour)     _colour_mode="$_arg" ;;
				esac
		done

		_debug::resolve_colour "$_colour_mode" && local _colour_enabled=1 || local _colour_enabled=0
		_debug::colour_vars "$_colour_enabled"

		# Verify the variable exists
		if ! declare -p "$_name" &>/dev/null; then
				echo "debug::vardump: variable ${_name@Q} not defined" >&2
				return 1
		fi

		# Parse attributes
		local _attrs
		IFS='' read -ra _attrs <<< "${!_name@a}"

		local _attr _typ=''
		local -a _attr_labels=()
		for _attr in "${_attrs[@]}"; do
				case "$_attr" in
						a) _attr_labels+=("(a)indexed array");      _typ='a' ;;
						A) _attr_labels+=("(A)associative array");   _typ='A' ;;
						r) _attr_labels+=("(r)read-only") ;;
						i) _attr_labels+=("(i)integer") ;;
						g) _attr_labels+=("(g)global") ;;
						x) _attr_labels+=("(x)exported") ;;
						*) _attr_labels+=("(?)unknown") ;;
				esac
		done

		# Verbose header
		if $_verbose; then
				echo "${_dc_dim}--------------------------${_dc_rst}"
				echo "${_dc_dim}debug::vardump: ${_dc_rst}$_name"

				echo -n "${_dc_dim}attributes: ${_dc_rst}"
				if [[ -n "${_attr_labels[*]}" ]]; then
						(IFS=/; echo -n "${_attr_labels[*]}")
				else
						echo -n '(none)'
				fi
				echo
		fi

		# Print the value
		local -n __debug_vardump_name="$_name"

		if [[ "$_typ" == 'a' || "$_typ" == 'A' ]]; then
				if $_verbose; then
						local _length=${#__debug_vardump_name[@]}
						printf '%s %s\n' \
								"${_dc_dim}length:${_dc_rst}" \
								"${_dc_magenta}$_length${_dc_rst}"
				fi

				echo '('
				local _key _value
				for _key in "${!__debug_vardump_name[@]}"; do
						_value=${__debug_vardump_name[$_key]}
						[[ "$_typ" == 'A' ]] && _key=${_key@Q}
						_value=${_value@Q}
						printf '\t[%s]=%s\n' \
								"${_dc_magenta}$_key${_dc_rst}" \
								"${_dc_green}$_value${_dc_rst}"
				done
				echo ')'
		else
				echo "${_dc_green}${__debug_vardump_name@Q}${_dc_rst}"
		fi

		if $_verbose; then
				echo "${_dc_dim}--------------------------${_dc_rst}"
		fi

		return 0
}
```


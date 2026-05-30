#!/usr/bin/env bash
# debug.sh — bash::framehead debug introspection lib
#
# Adapted from Dave Eddy's bash-vardump and bash-stacktrace (MIT license).
#
# Requires: runtime.sh

# --- COLOUR SETUP (shared by all debug functions) ---

# Resolve colour mode from positional argument.
# Usage: _debug::resolve_colour <autocolour|colour|mono>
_debug::resolve_colour() {
		local _mode="${1:-autocolour}"
		case "$_mode" in
				colour)         return 0 ;;  # force colour on
				mono|nocolour)  return 1 ;;  # force colour off
				autocolour|*)   [[ -t 1 ]] && return 0 || return 1 ;;
		esac
}

# Emit ANSI colour variables if colour is enabled.
# Call this at the start of each public function after parsing args.
# Usage: _debug::colour_vars <colour_mode>
_debug::colour_vars() {
		local _enable=$1
		if (( _enable )); then
				_dc_green=$'\e[32m'
				_dc_magenta=$'\e[35m'
				_dc_cyan=$'\e[36m'
				_dc_dim=$'\e[2m'
				_dc_rst=$'\e[0m'
		else
				_dc_green=''
				_dc_magenta=''
				_dc_cyan=''
				_dc_dim=''
				_dc_rst=''
		fi
}

# --- VARDUMP ---

# Pretty-print a variable's contents and metadata to stdout.
#
# Usage: debug::vardump <varname> [autocolour|colour|mono] [verbose]
#
# Examples:
#   declare -A assoc=([foo]=1 [bar]=2)
#   debug::vardump assoc
#   debug::vardump assoc verbose
#   debug::vardump assoc colour verbose
#   debug::vardump assoc mono
#
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

# --- STACKTRACE ---

# Print a formatted call-stack trace to stdout.
#
# Usage: debug::stacktrace [autocolour|colour|mono]
#
# Walk FUNCNAME / BASH_SOURCE / BASH_LINENO to show each frame.
#
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

# TRACE REDIRECTION
#
# BASH_XTRACEFD (Bash 4.1+) redirects set -x output to a file descriptor
# instead of stderr. Useful for debugging without polluting terminal output.
#
# All functions take/return fd state. Caller manages the fd lifecycle.
# Usage: read -r _trace_fd <<< "$(debug::trace_to_file /tmp/debug.log "$_trace_fd")"

# Redirect set -x output to a file. Echoes the allocated fd.
# Usage: debug::trace_to_file <path> [prev_fd]
debug::trace_to_file() {
		local _path=$1 _prev_fd="${2:-0}"
		[[ -n "$_path" ]] || { echo "debug::trace_to_file: path required" >&2; return 1; }

		# Close previous trace fd if active.
		if (( _prev_fd > 0 )); then
				eval "exec ${_prev_fd}>&-" 2>/dev/null || true
		fi

		# Auto-allocate a fd to the log file.
		local _fd
		eval "exec {_fd}>'$_path'" || return 1
		BASH_XTRACEFD=$_fd
		echo "$_fd"
}

# Restore set -x output to stderr and close the trace file.
# Usage: debug::trace_off [fd]
debug::trace_off() {
		local _fd="${1:-0}"
		BASH_XTRACEFD=2
		if (( _fd > 0 )); then
				eval "exec ${_fd}>&-" 2>/dev/null || true
		fi
}


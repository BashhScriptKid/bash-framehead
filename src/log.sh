#!/usr/bin/env bash

# log.sh — bash::framehead logging module
#
# Provides levelled logging with configurable format, output routing,
# and colour support. Configuration lives in a caller-owned associative
# array (TUI _ctx pattern). If no _ctx is provided, falls back to a
# lazy-initialized default config.
#
# CONFIGURATION (_ctx keys):
#   fmt          Format string using %token% placeholders
#                Default: "%datetime% [%severity%] %message%"
#   file         Path to log file. Empty = no file output.
#   stdout_mask  Bitmask controlling which levels go to stdout vs stderr.
#                Levels not in the mask go to stderr instead.
#                Use Bash base notation: 2#0011 = debug + info to stdout
#                bit 0 = debug, bit 1 = info, bit 2 = warn, bit 3 = error
#                Default: 2#0011 (warn + error -> stderr)
#   colour       1 = enable colour output, 0 = disable. Default: auto-detect.
#
# FORMAT TOKENS:
#   %timestamp%      Unix timestamp (seconds)
#   %datetime%       Human readable: 2025-02-27 14:32:11
#   %severity%       Uppercase: DEBUG, INFO, WARN, ERROR
#   %severity_lower% Lowercase: debug, info, warn, error
#   %message%        The log message
#   %script%         Calling script name ($0)
#   %pid%            Current process ID
#   %line%           Line number of the log call in the calling script
#   %func%           Function name that made the log call
#
# USAGE:
#   # With caller-owned config:
#   declare -A _log_cfg
#   _log_cfg[file]="/var/log/myscript.log"
#   _log_cfg[stdout_mask]="2#1100"
#   log::init _log_cfg
#
#   log::info _log_cfg "Starting up"
#   log::error _log_cfg "Failed to connect" 1
#
#   # With default config (no _ctx):
#   log::info "Starting up"

# --- CONSTANTS ---

readonly LOG_DEBUG=0
readonly LOG_INFO=1
readonly LOG_WARN=2
readonly LOG_ERROR=3

# ANSI colour codes — defined locally, no colour module dependency
readonly _LOG_COLOUR_CYAN='\033[0;36m'
readonly _LOG_COLOUR_GREEN='\033[0;32m'
readonly _LOG_COLOUR_YELLOW='\033[0;33m'
readonly _LOG_COLOUR_RED='\033[0;31m'
readonly _LOG_COLOUR_RESET='\033[0m'

# --- DEFAULT CONFIG ---

# Lazy-initialized default config (used when no _ctx is provided).
declare -A _LOG_CONFIG=()

_log::ensure_defaults() {
		[[ ${#_LOG_CONFIG[@]} -gt 0 ]] && return
		_LOG_CONFIG[fmt]='%datetime% [%severity%] %message%'
		_LOG_CONFIG[file]=''
		_LOG_CONFIG[stdout_mask]='2#0011'
		if [[ -t 1 && "${TERM:-}" != "dumb" && ( -n "${COLORTERM:-}" || "${TERM:-}" == *color* || "${TERM:-}" == *256* ) ]]; then
				_LOG_CONFIG[colour]=1
		else
				_LOG_CONFIG[colour]=0
		fi
}

# --- INIT ---

# Populate a caller's _ctx from defaults, filling blank fields.
# Usage: log::init _ctx
log::init() {
		local -n _lctx="$1"
		_log::ensure_defaults
		[[ -z "${_lctx[fmt]:-}" ]]         && _lctx[fmt]="${_LOG_CONFIG[fmt]}"
		[[ -z "${_lctx[file]:-}" ]]        && _lctx[file]="${_LOG_CONFIG[file]}"
		[[ -z "${_lctx[stdout_mask]:-}" ]] && _lctx[stdout_mask]="${_LOG_CONFIG[stdout_mask]}"
		[[ -z "${_lctx[colour]+x}" ]]      && _lctx[colour]="${_LOG_CONFIG[colour]}"
}

# --- INTERNAL ---

# Strip ANSI escape codes from a string
# Usage: _log::strip_colour string
_log::strip_colour() {
		# shellcheck disable=SC2001
		sed 's/\x1b\[[0-9;]*m//g' <<< "$1"
}

# Format a log line using fmt token substitution
# Usage: _log::format _ctx severity message caller_line caller_func
_log::format() {
		local -n _lctx="$1"; shift
		local severity="$1" msg="$2" caller_line="$3" caller_func="$4"
		local fmt="${_lctx[fmt]}"

		fmt="${fmt//%timestamp%/$(date +%s)}"
		fmt="${fmt//%datetime%/$(date '+%Y-%m-%d %H:%M:%S')}"
		fmt="${fmt//%severity%/$severity}"
		fmt="${fmt//%severity_lower%/${severity,,}}"
		fmt="${fmt//%message%/$msg}"
		fmt="${fmt//%script%/$0}"
		fmt="${fmt//%pid%/$$}"
		fmt="${fmt//%line%/$caller_line}"
		fmt="${fmt//%func%/$caller_func}"

		echo "$fmt"
}

# Apply ANSI colour to a line based on severity
# Usage: _log::colourise _ctx severity line
_log::colourise() {
		local -n _lctx="$1"; shift
		local severity="$1" line="$2"
		(( ${_lctx[colour]} )) || { echo "$line"; return; }
		local colour
		case "$severity" in
				DEBUG) colour="$_LOG_COLOUR_CYAN"   ;;
				INFO)  colour="$_LOG_COLOUR_GREEN"  ;;
				WARN)  colour="$_LOG_COLOUR_YELLOW" ;;
				ERROR) colour="$_LOG_COLOUR_RED"    ;;
				*)     echo "$line"; return         ;;
		esac
		printf '%b%s%b\n' "$colour" "$line" "$_LOG_COLOUR_RESET"
}

# Core emit function — format, route, and output a log line
# Usage: _log::emit ctx_name severity level_bit message caller_line caller_func
_log::emit() {
		local _ctx_ref="$1"; shift
		local -n _lctx="$_ctx_ref"
		local severity="$1" bit="$2" msg="$3" caller_line="$4" caller_func="$5"

		local line
		line=$(_log::format "$_ctx_ref" "$severity" "$msg" "$caller_line" "$caller_func")

		local should_stdout=$(( (${_lctx[stdout_mask]} >> bit) & 1 ))

		if (( should_stdout )); then
				_log::colourise "$_ctx_ref" "$severity" "$line" >&1
		else
				_log::colourise "$_ctx_ref" "$severity" "$line" >&2
		fi

		if [[ -n "${_lctx[file]}" ]]; then
				_log::strip_colour "$line" >> "${_lctx[file]}"
		fi
}

# --- PUBLIC API ---

# Log a debug message
# Useful for verbose tracing during development — typically suppressed in production
# Usage: log::debug [ctx] message
# Example:
#   log::debug "processing file: $filename"
#   log::debug _log_cfg "processing file: $filename"
log::debug() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		_log::emit "$_ctx_name" "DEBUG" $LOG_DEBUG "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log an informational message
# Usage: log::info [ctx] message
# Example:
#   log::info "server started on port $port"
log::info() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		_log::emit "$_ctx_name" "INFO" $LOG_INFO "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log a warning message
# Indicates something unexpected but recoverable
# Usage: log::warn [ctx] message
# Example:
#   log::warn "config not found, using defaults"
log::warn() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		_log::emit "$_ctx_name" "WARN" $LOG_WARN "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log an error message, optionally exiting with a given code
# If a second argument is provided and is an integer, exits with that code after logging
# Usage: log::error [ctx] message [exit_code]
# Example:
#   log::error "failed to connect to database"
#   log::error "permission denied" 126
#   log::error _log_cfg "permission denied" 126
log::error() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		local msg="$1"
		local exit_code="${2:-}"
		_log::emit "$_ctx_name" "ERROR" $LOG_ERROR "$msg" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
		if [[ -n "$exit_code" && "$exit_code" =~ ^-?[0-9]+$ ]]; then
				exit "$exit_code"
		fi
}

# Log an error and always exit, defaulting to exit code 1
# Shorthand for log::error with guaranteed exit
# Usage: log::fatal [ctx] message [exit_code]
# Example:
#   log::fatal "cannot continue without config file"
#   log::fatal _log_cfg "unsupported OS" 2
log::fatal() {
		local _ctx_name
		if [[ $# -gt 0 ]] && declare -p "$1" 2>/dev/null | grep -q 'declare.*-A'; then
				_ctx_name="$1"; shift
		else
				_log::ensure_defaults
				_ctx_name="_LOG_CONFIG"
		fi
		local msg="$1"
		local exit_code="${2:-1}"
		_log::emit "$_ctx_name" "ERROR" $LOG_ERROR "$msg" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
		exit "$exit_code"
}

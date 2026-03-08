#!/usr/bin/env bash

# log.sh — bash::framehead logging module
#
# Provides levelled logging with configurable format, output routing,
# and colour support. All behaviour is controlled via environment variables
# so scripts can configure logging without touching function calls.
#
# CONFIGURATION:
#   LOG_FMT          Format string using %token% placeholders
#                    Default: "%datetime% [%severity%] %message%"
#   LOG_FILE         Path to log file. Empty = no file output.
#   LOG_TO_STDOUT    Bitmask controlling which levels go to stdout vs stderr.
#                    Levels not in the mask go to stderr instead.
#                    Use Bash base notation: 2#0011 = debug + info to stdout
#                    bit 0 = debug, bit 1 = info, bit 2 = warn, bit 3 = error
#                    Default: 2#0011 (warn + error → stderr)
#   LOG_COLOUR       1 = enable colour output, 0 = disable. Default: auto-detect.
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
# EXAMPLE:
#   LOG_FMT="%datetime% [%severity%] (%func%:%line%) %message%"
#   LOG_FILE="/var/log/myscript.log"
#   LOG_TO_STDOUT=2#1100  # warn + error to stdout, debug + info to stderr
#
#   log::info  "Starting up"
#   log::warn  "Config not found, using defaults"
#   log::error "Failed to connect" 1   # logs then exits 1

# ==============================================================================
# CONSTANTS
# ==============================================================================

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

# ==============================================================================
# DEFAULTS
# ==============================================================================

# Initialise config vars if not already set by the caller
log::init() {
    LOG_FMT="${LOG_FMT:-%datetime% [%severity%] %message%}"
    LOG_FILE="${LOG_FILE:-}"
    LOG_TO_STDOUT="${LOG_TO_STDOUT:-2#0011}"
    if [[ -z "${LOG_COLOUR+x}" ]]; then
        # Auto-detect: enable if terminal supports colour
        if [[ -t 1 && "${TERM:-}" != "dumb" && ( -n "${COLORTERM:-}" || "${TERM:-}" == *color* || "${TERM:-}" == *256* ) ]]; then
            LOG_COLOUR=1
        else
            LOG_COLOUR=0
        fi
    fi
}

# ==============================================================================
# INTERNAL
# ==============================================================================

# Strip ANSI escape codes from a string
# Usage: _log::strip_colour string
_log::strip_colour() {
    sed 's/\x1b\[[0-9;]*m//g' <<< "$1"
}

# Format a log line using LOG_FMT token substitution
# Usage: _log::format severity message caller_line caller_func
_log::format() {
    local fmt="${LOG_FMT}"

    fmt="${fmt//%timestamp%/$(date +%s)}"
    fmt="${fmt//%datetime%/$(date '+%Y-%m-%d %H:%M:%S')}"
    fmt="${fmt//%severity%/$1}"
    fmt="${fmt//%severity_lower%/${1,,}}"
    fmt="${fmt//%message%/$2}"
    fmt="${fmt//%script%/$0}"
    fmt="${fmt//%pid%/$$}"
    fmt="${fmt//%line%/$3}"
    fmt="${fmt//%func%/$4}"

    echo "$fmt"
}

# Apply ANSI colour to a line based on severity
# Usage: _log::colourise severity line
_log::colourise() {
    (( LOG_COLOUR )) || { echo "$2"; return; }
    local colour
    case "$1" in
        DEBUG) colour="$_LOG_COLOUR_CYAN"   ;;
        INFO)  colour="$_LOG_COLOUR_GREEN"  ;;
        WARN)  colour="$_LOG_COLOUR_YELLOW" ;;
        ERROR) colour="$_LOG_COLOUR_RED"    ;;
        *)     echo "$2"; return         ;;
    esac
    printf '%b%s%b\n' "$colour" "$2" "$_LOG_COLOUR_RESET"
}

# Core emit function — format, route, and output a log line
# Usage: _log::emit severity level_bit message caller_line caller_func
_log::emit() {
    # Ensure defaults are set
    [[ -z "${LOG_FMT+x}" ]] && log::init

    local line
    line=$(_log::format "$1" "$3" "$4" "$5")

    local should_stdout=$(( (LOG_TO_STDOUT >> $2) & 1 ))

    if (( should_stdout )); then
        _log::colourise "$1" "$line" >&1
    else
        _log::colourise "$1" "$line" >&2
    fi

    if [[ -n "$LOG_FILE" ]]; then
        _log::strip_colour "$line" >> "$LOG_FILE"
    fi
}

# ==============================================================================
# PUBLIC API
# ==============================================================================

# Log a debug message
# Useful for verbose tracing during development — typically suppressed in production
# Usage: log::debug message
# Example:
#   log::debug "processing file: $filename"
log::debug() {
    _log::emit "DEBUG" $LOG_DEBUG "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log an informational message
# Usage: log::info message
# Example:
#   log::info "server started on port $port"
log::info() {
    _log::emit "INFO" $LOG_INFO "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log a warning message
# Indicates something unexpected but recoverable
# Usage: log::warn message
# Example:
#   log::warn "config not found, using defaults"
log::warn() {
    _log::emit "WARN" $LOG_WARN "$*" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
}

# Log an error message, optionally exiting with a given code
# If a second argument is provided and is an integer, exits with that code after logging
# Usage: log::error message [exit_code]
# Example:
#   log::error "failed to connect to database"
#   log::error "permission denied" 126
log::error() {
    local exit_code="${2:-}"
    _log::emit "ERROR" $LOG_ERROR "$1" "${BASH_LINENO[0]}" "${FUNCNAME[1]}"
    if [[ -n "$exit_code" && "$exit_code" =~ ^-?[0-9]+$ ]]; then
        exit "$exit_code"
    fi
}

# Log an error and always exit, defaulting to exit code 1
# Shorthand for log::error with guaranteed exit
# Usage: log::fatal message [exit_code]
# Example:
#   log::fatal "cannot continue without config file"
#   log::fatal "unsupported OS" 2
log::fatal() {
    log::error "$1" "${2:-1}"
}

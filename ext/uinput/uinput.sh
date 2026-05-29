# shellcheck shell=bash
# ext/uinput.sh — uinput virtual device extension
# Requires: runtime.sh (runtime::has_command, runtime::is_root)
#
# Provides Bash wrappers for creating and interacting with uinput virtual
# devices via a compiled C helper binary.
#
# Build: cd ext/uinput && make
# Usage: source ext/uinput/uinput.sh

# --- Guard ---

_UINPUT_HELPER="$(dirname "${BASH_SOURCE[0]}")/uinput/uinput_helper"

# --- Read-only ---

uinput::is_ready() {
		[[ -x "$_UINPUT_HELPER" ]]
}

# --- Write APIs (require root + helper binary) ---

uinput::create() {
		local _name="${1:-bashframehead-virtual}"
		uinput::is_ready || { echo "uinput::create: helper not compiled (run: cd ext/uinput && make)" >&2; return 1; }
		runtime::is_root || { echo "uinput::create: requires root" >&2; return 1; }
		"$_UINPUT_HELPER" create "$_name"
}

uinput::destroy() {
		local _path="$1"
		uinput::is_ready || { echo "uinput::destroy: helper not compiled" >&2; return 1; }
		runtime::is_root || { echo "uinput::destroy: requires root" >&2; return 1; }
		"$_UINPUT_HELPER" destroy "$_path"
}

uinput::key() {
		local _path="$1" _code="$2" _value="${3:-1}"
		uinput::is_ready || { echo "uinput::key: helper not compiled" >&2; return 1; }
		runtime::is_root || { echo "uinput::key: requires root" >&2; return 1; }
		"$_UINPUT_HELPER" key "$_path" "$_code" "$_value"
}

uinput::mouse() {
		local _path="$1" _dx="$2" _dy="$3"
		uinput::is_ready || { echo "uinput::mouse: helper not compiled" >&2; return 1; }
		runtime::is_root || { echo "uinput::mouse: requires root" >&2; return 1; }
		"$_UINPUT_HELPER" mouse "$_path" "$_dx" "$_dy"
}

uinput::abs() {
		local _path="$1" _code="$2" _value="$3"
		uinput::is_ready || { echo "uinput::abs: helper not compiled" >&2; return 1; }
		runtime::is_root || { echo "uinput::abs: requires root" >&2; return 1; }
		"$_UINPUT_HELPER" abs "$_path" "$_code" "$_value"
}

uinput::event() {
		local _path="$1" _type="$2" _code="$3" _value="$4"
		uinput::is_ready || { echo "uinput::event: helper not compiled" >&2; return 1; }
		runtime::is_root || { echo "uinput::event: requires root" >&2; return 1; }
		"$_UINPUT_HELPER" event "$_path" "$_type" "$_code" "$_value"
}

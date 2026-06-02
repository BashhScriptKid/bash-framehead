# shellcheck shell=bash
# ext/dbus.sh -- D-Bus client for bash-framehead
# Requires: runtime
#
# Wraps busctl (preferred) or gdbus to provide method calls, properties,
# introspection, and signal handling against system and session buses.
#
# CONFIGURATION:
#   _DBUS_BACKEND      Chosen backend at source time: "busctl" or "gdbus".
#   _DBUS_DEFAULT_BUS  Current default bus for this shell. Default: "session".
#
# EXAMPLE:
#   source bash-framehead.sh
#   source ext/dbus/dbus.sh
#   dbus::list::session                     # see what's on the session bus
#   dbus::pinpoint org.freedesktop.Notifications   # -> :1.42
#   dbus::call org.freedesktop.DBus /org/freedesktop/DBus \
#       org.freedesktop.DBus GetId
#   dbus::watch org.freedesktop.Notifications | while read -r line; do ...; done

# --- Guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: runtime not found -- source bash-framehead.sh first" >&2
	return 1
}

_guard_core_deps=()
_guard_ext_deps=()
_guard_ext_deps_any=(busctl gdbus)

for _guard_dep in "${_guard_core_deps[@]}"; do
	declare -f "$_guard_dep" &>/dev/null || {
		echo "${BASH_SOURCE[0]}: missing core function '$_guard_dep'" >&2
		return 1
	}
done

for _guard_dep in "${_guard_ext_deps[@]}"; do
	command -v "$_guard_dep" &>/dev/null || {
		echo "${BASH_SOURCE[0]}: missing external tool '$_guard_dep'" >&2
		return 1
	}
done

# At least one of _guard_ext_deps_any must be present.
_guard_any_found=0
for _guard_dep in "${_guard_ext_deps_any[@]}"; do
	if command -v "$_guard_dep" &>/dev/null; then
		_guard_any_found=1
		break
	fi
done
if (( _guard_any_found == 0 )); then
	echo "${BASH_SOURCE[0]}: need one of: ${_guard_ext_deps_any[*]}" >&2
	unset _guard_core_deps _guard_ext_deps _guard_ext_deps_any _guard_dep _guard_any_found
	return 1
fi

unset _guard_core_deps _guard_ext_deps _guard_ext_deps_any _guard_dep _guard_any_found
# --- end guard ---

# --- Backend detection ---
# Prefer busctl: type-aware output, structured introspection, optional JSON.
# Fall back to gdbus when only glib2 is available (non-systemd systems).

if command -v busctl &>/dev/null; then
	_DBUS_BACKEND="busctl"
elif command -v gdbus &>/dev/null; then
	_DBUS_BACKEND="gdbus"
fi
readonly _DBUS_BACKEND

# --- Constants ---

_DBUS_DEFAULT_BUS="${_DBUS_DEFAULT_BUS:-session}"

# --- Internal helpers ---

# Echo the busctl flag for the current bus, e.g. "--user" or "--system".
_dbus::bus_flag() {
	case "$_DBUS_DEFAULT_BUS" in
		session) echo "--user" ;;
		system)  echo "--system" ;;
		*)
			echo "_dbus::bus_flag: bad bus '$_DBUS_DEFAULT_BUS'" >&2
			return 1
			;;
	esac
}

# Echo the busctl flag for a named bus passed as argument.
# Usage: _dbus::bus_flag_for <session|system>
_dbus::bus_flag_for() {
	case "$1" in
		session) echo "--user" ;;
		system)  echo "--system" ;;
		*)
			echo "_dbus::bus_flag_for: bad bus '$1'" >&2
			return 1
			;;
	esac
}

# --- Bus selection ---

# Echo the current default bus ("session" or "system").
dbus::bus::get() {
	echo "$_DBUS_DEFAULT_BUS"
}

# Set the default bus for this shell. Subsequent calls without an explicit
# bus argument use this selection.
# Usage: dbus::bus::set <session|system>
dbus::bus::set() {
	local bus="$1"
	case "$bus" in
		session|system)
			_DBUS_DEFAULT_BUS="$bus"
			;;
		*)
			echo "dbus::bus::set: bus must be 'session' or 'system' (got '$bus')" >&2
			return 1
			;;
	esac
}

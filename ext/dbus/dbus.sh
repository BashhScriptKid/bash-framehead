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

# --- Listing ---

# Print bare bus names (one per line) on the given bus, skipping the header.
# Usage: _dbus::list_raw <session|system> [--activatable]
_dbus::list_raw() {
	local bus="$1" mode="${2:-}"
	local flag
	flag=$(_dbus::bus_flag_for "$bus") || return 1

	local args=("$flag" "list" "--no-pager" "--no-legend")
	[[ "$mode" == "--activatable" ]] && args+=("--activatable")

	# busctl list with --no-legend skips the header; column 1 is the name.
	busctl "${args[@]}" 2>/dev/null | awk '{ print $1 }'
}

# Print all bus names, annotated with their bus. Output: <bus>\t<name>
# Usage: dbus::list
dbus::list() {
	local name
	while IFS= read -r name; do
		printf 'session\t%s\n' "$name"
	done < <(_dbus::list_raw session)
	while IFS= read -r name; do
		printf 'system\t%s\n' "$name"
	done < <(_dbus::list_raw system)
}

# Print bare bus names on the session bus, one per line.
# Usage: dbus::list::session
dbus::list::session() {
	_dbus::list_raw session
}

# Print bare bus names on the system bus, one per line.
# Usage: dbus::list::system
dbus::list::system() {
	_dbus::list_raw system
}

# Print all autostartable (activatable) services, annotated with their bus.
# Output: <bus>\t<name>
# Usage: dbus::list::autostarts
dbus::list::autostarts() {
	local name
	while IFS= read -r name; do
		printf 'session\t%s\n' "$name"
	done < <(_dbus::list_raw session --activatable)
	while IFS= read -r name; do
		printf 'system\t%s\n' "$name"
	done < <(_dbus::list_raw system --activatable)
}

# Print autostartable services on the session bus, one per line.
# Usage: dbus::list::autostarts::session
dbus::list::autostarts::session() {
	_dbus::list_raw session --activatable
}

# Print autostartable services on the system bus, one per line.
# Usage: dbus::list::autostarts::system
dbus::list::autostarts::system() {
	_dbus::list_raw system --activatable
}

# --- Name resolution ---

# Print the unique connection name (e.g. ":1.42") that currently owns the
# given well-known name. Prints nothing and returns non-zero if unowned.
# Usage: dbus::pinpoint <name>
dbus::pinpoint() {
	local name="$1"
	if [[ -z "$name" ]]; then
		echo "dbus::pinpoint: name required" >&2
		return 1
	fi
	local flag raw
	flag=$(_dbus::bus_flag) || return 1
	raw=$(busctl "$flag" call \
		org.freedesktop.DBus /org/freedesktop/DBus \
		org.freedesktop.DBus GetNameOwner s "$name" 2>/dev/null) || return 1
	# raw looks like: s ":1.42"
	# Strip leading 's ' and surrounding quotes.
	raw="${raw#s }"
	raw="${raw#\"}"
	raw="${raw%\"}"
	echo "$raw"
}

# Exit 0 if the given well-known name is currently claimed, 1 otherwise.
# Usage: dbus::owned <name>
dbus::owned() {
	local name="$1"
	if [[ -z "$name" ]]; then
		echo "dbus::owned: name required" >&2
		return 2
	fi
	local flag raw
	flag=$(_dbus::bus_flag) || return 2
	raw=$(busctl "$flag" call \
		org.freedesktop.DBus /org/freedesktop/DBus \
		org.freedesktop.DBus NameHasOwner s "$name" 2>/dev/null) || return 2
	# raw looks like: b true   or   b false
	[[ "$raw" == "b true" ]]
}

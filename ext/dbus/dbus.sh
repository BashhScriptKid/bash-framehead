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

# --- Method calls ---

# Invoke a method on a D-Bus object. Output is raw busctl format:
# '<sig> <values...>' on a single line, or empty for void methods.
# Use dbus::fromsig to parse the result.
# Usage: dbus::call <service> <path> <interface> <method> [sig] [args...]
dbus::call() {
	if (( $# < 4 )); then
		echo "dbus::call: need <service> <path> <interface> <method> [sig args...]" >&2
		return 1
	fi
	local flag
	flag=$(_dbus::bus_flag) || return 1
	busctl "$flag" call "$@"
}

# --- Properties ---

# Read a single property. Output is raw busctl format '<sig> <value>'.
# Use dbus::fromsig to parse the result.
# Usage: dbus::get <service> <path> <interface> <property>
dbus::get() {
	if (( $# != 4 )); then
		echo "dbus::get: need <service> <path> <interface> <property>" >&2
		return 1
	fi
	local flag
	flag=$(_dbus::bus_flag) || return 1
	busctl "$flag" get-property "$@"
}

# Write a single property.
# Usage: dbus::set <service> <path> <interface> <property> <sig> <value>
dbus::set() {
	if (( $# != 6 )); then
		echo "dbus::set: need <service> <path> <interface> <property> <sig> <value>" >&2
		return 1
	fi
	local flag
	flag=$(_dbus::bus_flag) || return 1
	busctl "$flag" set-property "$@"
}

# Dump all properties on an interface. Output is raw busctl format
# 'a{sv} <count> <key> <inner_sig> <value> ...' on a single line.
# Use dbus::fromsig to parse into <key>\t<value> pairs.
# Usage: dbus::get::all <service> <path> <interface>
dbus::get::all() {
	if (( $# != 3 )); then
		echo "dbus::get::all: need <service> <path> <interface>" >&2
		return 1
	fi
	local service="$1" path="$2" iface="$3"
	local flag
	flag=$(_dbus::bus_flag) || return 1
	busctl "$flag" call "$service" "$path" \
		org.freedesktop.DBus.Properties GetAll s "$iface"
}

# --- Introspection ---

# Internal: run busctl introspect with consistent flags.
# Usage: _dbus::introspect_raw <service> <path>
_dbus::introspect_raw() {
	local flag
	flag=$(_dbus::bus_flag) || return 1
	busctl "$flag" introspect --no-pager --no-legend "$1" "$2" 2>/dev/null
}

# Print the raw introspection table for an object (busctl-formatted).
# Columns: NAME TYPE SIGNATURE RESULT/VALUE FLAGS.
# Usage: dbus::introspect <service> <path>
dbus::introspect() {
	if (( $# != 2 )); then
		echo "dbus::introspect: need <service> <path>" >&2
		return 1
	fi
	_dbus::introspect_raw "$1" "$2"
}

# List interface names on an object, one per line.
# Usage: dbus::interfaces <service> <path>
dbus::interfaces() {
	if (( $# != 2 )); then
		echo "dbus::interfaces: need <service> <path>" >&2
		return 1
	fi
	_dbus::introspect_raw "$1" "$2" | awk '$2 == "interface" { print $1 }'
}

# List method names on a given interface, one per line. Names are emitted
# without the leading dot that busctl prefixes.
# Usage: dbus::methods <service> <path> <interface>
dbus::methods() {
	if (( $# != 3 )); then
		echo "dbus::methods: need <service> <path> <interface>" >&2
		return 1
	fi
	_dbus::introspect_raw "$1" "$2" | awk -v target="$3" '
		$2 == "interface" { current = $1; next }
		current == target && $2 == "method" {
			name = $1; sub(/^\./, "", name); print name
		}
	'
}

# List signal names on a given interface, one per line.
# Usage: dbus::signals <service> <path> <interface>
dbus::signals() {
	if (( $# != 3 )); then
		echo "dbus::signals: need <service> <path> <interface>" >&2
		return 1
	fi
	_dbus::introspect_raw "$1" "$2" | awk -v target="$3" '
		$2 == "interface" { current = $1; next }
		current == target && $2 == "signal" {
			name = $1; sub(/^\./, "", name); print name
		}
	'
}

# List property names on a given interface, one per line.
# Usage: dbus::properties <service> <path> <interface>
dbus::properties() {
	if (( $# != 3 )); then
		echo "dbus::properties: need <service> <path> <interface>" >&2
		return 1
	fi
	_dbus::introspect_raw "$1" "$2" | awk -v target="$3" '
		$2 == "interface" { current = $1; next }
		current == target && $2 == "property" {
			name = $1; sub(/^\./, "", name); print name
		}
	'
}

# --- Signals ---

# Internal: stream signals matching the given interface (and optional member)
# as one-line TSV records:
#   <unix_ts>\t<sender>\t<path>\t<interface>\t<member>\t<sig>\t<args_json>
# Filters at the bus level via --match. Args are JSON-encoded best-effort:
# flat STRING/INT/UINT/BOOLEAN/DOUBLE values land cleanly; nested arrays
# and complex containers degrade (the count token leaks through).
# Usage: _dbus::signal_stream <interface> [member]
_dbus::signal_stream() {
	local iface="$1" member="${2:-}"
	local flag match
	flag=$(_dbus::bus_flag) || return 1
	match="type='signal',interface='$iface'"
	[[ -n "$member" ]] && match+=",member='$member'"

	busctl "$flag" monitor --match "$match" 2>/dev/null | awk -v want_iface="$iface" -v want_member="$member" '
		function flush() {
			if (rtype == "signal" \
			    && (want_iface == "" || iface == want_iface) \
			    && (want_member == "" || member == want_member)) {
				printf "%s\t%s\t%s\t%s\t%s\t%s\t[%s]\n", \
					systime(), sender, path, iface, member, sig, args
				fflush()
			}
		}
		/^‣ Type=/ {
			flush()
			rtype=""; sender=""; path=""; iface=""; member=""; sig=""; args=""; in_msg=0
			for (i=1; i<=NF; i++) {
				if ($i ~ /^Type=/) { rtype = substr($i, 6) }
			}
			next
		}
		/Sender=/ {
			if (match($0, /Sender=[^ ]+/))    { sender = substr($0, RSTART+7,  RLENGTH-7)  }
			if (match($0, /Path=[^ ]+/))      { path   = substr($0, RSTART+5,  RLENGTH-5)  }
			if (match($0, /Interface=[^ ]+/)) { iface  = substr($0, RSTART+10, RLENGTH-10) }
			if (match($0, /Member=[^ ]+/))    { member = substr($0, RSTART+7,  RLENGTH-7)  }
			next
		}
		/^  MESSAGE / {
			s = $0; sub(/.*MESSAGE "/, "", s); sub(/".*/, "", s); sig = s; in_msg = 1; next
		}
		in_msg && /STRING / {
			s = $0; sub(/^[ \t]*STRING "/, "", s); sub(/";[ \t]*$/, "", s)
			gsub(/\\/, "\\\\", s); gsub(/"/, "\\\"", s)
			if (args != "") args = args ","
			args = args "\"" s "\""; next
		}
		in_msg && /(UINT|INT)[0-9]+ / {
			s = $NF; sub(/;$/, "", s)
			if (args != "") args = args ","
			args = args s; next
		}
		in_msg && /BOOLEAN / {
			s = $NF; sub(/;$/, "", s)
			if (args != "") args = args ","
			args = args s; next
		}
		in_msg && /DOUBLE / {
			s = $NF; sub(/;$/, "", s)
			if (args != "") args = args ","
			args = args s; next
		}
		in_msg && /^};/ { in_msg = 0; next }
		END { flush() }
	'
}

# Block until one signal matching the interface (and optional member) arrives,
# print one TSV record, then exit. Optional timeout in seconds; exit 124 if
# the timeout fires before a signal (matching coreutils timeout convention).
# Usage: dbus::wait <interface> <signal> [timeout_seconds]
dbus::wait() {
	local iface="$1" member="$2" t="${3:-}"
	if [[ -z "$iface" || -z "$member" ]]; then
		echo "dbus::wait: need <interface> <signal> [timeout_seconds]" >&2
		return 1
	fi
	# Find the runtime source so we can re-source this file in a fresh bash.
	local self="${BASH_SOURCE[0]}"
	local runtime_src
	runtime_src="$(cd "${self%/*}/../.." 2>/dev/null && pwd)/src/runtime.sh"
	if [[ ! -f "$runtime_src" ]]; then
		echo "dbus::wait: cannot locate runtime.sh from '$self'" >&2
		return 1
	fi

	if [[ -n "$t" ]]; then
		# tmpfile + polling + process-group kill: the producer pipeline
		# (busctl | awk) sits in read() waiting for the next signal, so
		# SIGPIPE never propagates from a downstream head. We put the
		# producer in its own session and kill the group on timeout/cleanup.
		local tmpfile="/tmp/dbus-wait-$$-$BASHPID.tmp"
		rm -f "$tmpfile"
		setsid bash -c "
			source '$runtime_src' || exit 1
			source '$self' || exit 1
			_dbus::signal_stream '$iface' '$member' > '$tmpfile' 2>/dev/null
		" &
		local producer_pid=$!
		local deadline=$(( $(date +%s) + t ))
		while (( $(date +%s) < deadline )); do
			if [[ -s "$tmpfile" ]]; then
				head -n 1 "$tmpfile"
				kill -TERM -- -"$producer_pid" 2>/dev/null
				rm -f "$tmpfile"
				return 0
			fi
			sleep 0.1
		done
		kill -TERM -- -"$producer_pid" 2>/dev/null
		rm -f "$tmpfile"
		return 124
	else
		# No timeout: rely on the head -n 1 closing the pipe. Caller is
		# expected to wrap in timeout if needed.
		_dbus::signal_stream "$iface" "$member" | head -n 1
	fi
}

# Stream signals matching the interface (and optional member) as TSV records
# to stdout, one per line, forever. Pipe through 'while IFS=$'\''\t'\'' read ...'.
# Usage: dbus::watch <interface> [signal]
dbus::watch() {
	local iface="$1" member="${2:-}"
	if [[ -z "$iface" ]]; then
		echo "dbus::watch: need <interface> [signal]" >&2
		return 1
	fi
	_dbus::signal_stream "$iface" "$member"
}

# Bridge signals from the bus into a pubsub topic. Spawns a background process
# that forwards each TSV signal record to pubsub::publish. Returns the PID of
# the bridge on stdout; caller must store it and pass to dbus::unsubscribe.
# Usage: pid=$(dbus::subscribe <interface> <signal> <pubsub_topic>)
dbus::subscribe() {
	local iface="$1" member="$2" topic="$3"
	if [[ -z "$iface" || -z "$member" || -z "$topic" ]]; then
		echo "dbus::subscribe: need <interface> <signal> <pubsub_topic>" >&2
		return 1
	fi
	declare -f 'pubsub::publish' &>/dev/null || {
		echo "dbus::subscribe: pubsub module not available" >&2
		return 1
	}
	# Re-source dbus.sh + pubsub.sh in a fresh bash under setsid so
	# dbus::unsubscribe can kill the entire process group cleanly. The
	# busctl monitor pipeline sits in read(), so SIGPIPE never propagates.
	local self="${BASH_SOURCE[0]}"
	local lib_dir
	lib_dir="$(cd "${self%/*}/../.." 2>/dev/null && pwd)/src"
	local pubsub_src="$lib_dir/pubsub.sh"
	local runtime_src="$lib_dir/runtime.sh"
	if [[ ! -f "$pubsub_src" || ! -f "$runtime_src" ]]; then
		echo "dbus::subscribe: cannot locate runtime.sh or pubsub.sh" >&2
		return 1
	fi
	setsid bash -c "
		source '$runtime_src' || exit 1
		source '$pubsub_src' || exit 1
		source '$self' || exit 1
		_dbus::signal_stream '$iface' '$member' | \
			while IFS= read -r line; do
				printf '%s\n' \"\$line\" | pubsub::publish '$topic' 2>/dev/null || true
			done
	" &
	disown
	echo $!
}

# Stop a bridge spawned by dbus::subscribe. Kills the bridge's process group.
# Usage: dbus::unsubscribe <pid>
dbus::unsubscribe() {
	local pid="$1"
	if [[ -z "$pid" ]]; then
		echo "dbus::unsubscribe: pid required" >&2
		return 1
	fi
	kill -TERM -- -"$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || return 1
}

# --- Sig parser ---
# Parses raw busctl output of the form '<sig> <values...>' into bare values,
# one per line. Strings are unquoted. Arrays/dicts expand element-per-line
# (dict entries as <key>\t<value>). Composes with ::call, ::get, ::get::all.
#
# Supported sigs (v1):
#   y b n q i u x t d s o g          -- scalars
#   as ao ay an aq ai au ax at ad    -- flat arrays of scalars
#   a{ss} a{sv} a{si} a{su} a{sb}    -- common dicts
#   (...)                            -- structs (flat, scalar elements)
#   v                                -- variants (one level)
# Exotic / deeply nested sigs are emitted raw with a stderr warning.

# Tokenize a busctl value buffer into NUL-separated tokens on stdout.
# Strings are emitted with surrounding quotes stripped and \\\\, \", \\n, \\t, \\r
# escapes resolved. Other tokens emitted verbatim.
# Tokens themselves cannot contain NUL bytes (D-Bus strings are NUL-terminated
# and would terminate early if they did), so NUL is a safe separator.
# Usage: _dbus::tokenize_values "<buffer>"
_dbus::tokenize_values() {
	local buf="$1" len="${#1}" i=0 ch
	local token in_string=0 escape=0
	while (( i < len )); do
		ch="${buf:i:1}"
		if (( in_string )); then
			if (( escape )); then
				case "$ch" in
					n)  token+=$'\n' ;;
					t)  token+=$'\t' ;;
					r)  token+=$'\r' ;;
					\\) token+='\' ;;
					\") token+='"' ;;
					*)  token+="$ch" ;;
				esac
				escape=0
			elif [[ "$ch" == '\' ]]; then
				escape=1
			elif [[ "$ch" == '"' ]]; then
				printf '%s\0' "$token"
				token=""
				in_string=0
			else
				token+="$ch"
			fi
		else
			if [[ "$ch" == '"' ]]; then
				in_string=1
				token=""
			elif [[ "$ch" == ' ' || "$ch" == $'\t' ]]; then
				if [[ -n "$token" ]]; then
					printf '%s\0' "$token"
					token=""
				fi
			else
				token+="$ch"
			fi
		fi
		(( i++ ))
	done
	if [[ -n "$token" && in_string -eq 0 ]]; then
		printf '%s\0' "$token"
	fi
}

# Split a top-level signature into its component types.
# Examples:
#   "s"      -> ["s"]
#   "ss"     -> ["s", "s"]
#   "as"     -> ["as"]
#   "a{sv}"  -> ["a{sv}"]
#   "(ss)i"  -> ["(ss)", "i"]
# Emits one type per line.
_dbus::split_sig() {
	local sig="$1" len="${#1}" i=0 ch depth
	local tok=""
	while (( i < len )); do
		ch="${sig:i:1}"
		case "$ch" in
			a)
				# Array: 'a' + next type (which may be (...), {...}, or scalar)
				tok="a"
				(( i++ ))
				if (( i < len )); then
					ch="${sig:i:1}"
					case "$ch" in
						'(')
							depth=1; tok+="("; (( i++ ))
							while (( i < len )) && (( depth > 0 )); do
								ch="${sig:i:1}"; tok+="$ch"
								[[ "$ch" == '(' ]] && (( depth++ ))
								[[ "$ch" == ')' ]] && (( depth-- ))
								(( i++ ))
							done
							;;
						'{')
							depth=1; tok+="{"; (( i++ ))
							while (( i < len )) && (( depth > 0 )); do
								ch="${sig:i:1}"; tok+="$ch"
								[[ "$ch" == '{' ]] && (( depth++ ))
								[[ "$ch" == '}' ]] && (( depth-- ))
								(( i++ ))
							done
							;;
						*)
							tok+="$ch"; (( i++ ))
							;;
					esac
				fi
				printf '%s\n' "$tok"; tok=""
				;;
			'(')
				depth=1; tok="("; (( i++ ))
				while (( i < len )) && (( depth > 0 )); do
					ch="${sig:i:1}"; tok+="$ch"
					[[ "$ch" == '(' ]] && (( depth++ ))
					[[ "$ch" == ')' ]] && (( depth-- ))
					(( i++ ))
				done
				printf '%s\n' "$tok"; tok=""
				;;
			*)
				printf '%s\n' "$ch"
				(( i++ ))
				;;
		esac
	done
}

# Read tokens from the _dbus_tokens array (index _dbus_tok_idx) and emit
# parsed values for the given top-level type. Advances the index.
# Internal: uses globals _dbus_tokens (array) and _dbus_tok_idx (int).
_dbus::emit_one() {
	local type="$1"
	local count i tok inner
	case "$type" in
		s|o|g|y|b|n|q|i|u|x|t|d)
			printf '%s\n' "${_dbus_tokens[_dbus_tok_idx]}"
			(( _dbus_tok_idx++ ))
			;;
		'a{ss}'|'a{si}'|'a{su}'|'a{sb}'|'a{sd}'|'a{so}')
			count="${_dbus_tokens[_dbus_tok_idx]}"
			(( _dbus_tok_idx++ ))
			for (( i = 0; i < count; i++ )); do
				printf '%s\t%s\n' \
					"${_dbus_tokens[_dbus_tok_idx]}" \
					"${_dbus_tokens[_dbus_tok_idx + 1]}"
				(( _dbus_tok_idx += 2 ))
			done
			;;
		'a{sv}')
			count="${_dbus_tokens[_dbus_tok_idx]}"
			(( _dbus_tok_idx++ ))
			for (( i = 0; i < count; i++ )); do
				# key, then variant: <inner_sig> <value>
				printf '%s\t%s\n' \
					"${_dbus_tokens[_dbus_tok_idx]}" \
					"${_dbus_tokens[_dbus_tok_idx + 2]}"
				(( _dbus_tok_idx += 3 ))
			done
			;;
		a*)
			# Flat array of scalars: 'a' + one scalar char.
			count="${_dbus_tokens[_dbus_tok_idx]}"
			(( _dbus_tok_idx++ ))
			for (( i = 0; i < count; i++ )); do
				printf '%s\n' "${_dbus_tokens[_dbus_tok_idx]}"
				(( _dbus_tok_idx++ ))
			done
			;;
		'('*)
			# Struct: emit each inner type as a separate value.
			inner="${type:1:${#type}-2}"
			local sub
			while IFS= read -r sub; do
				_dbus::emit_one "$sub"
			done < <(_dbus::split_sig "$inner")
			;;
		v)
			# Variant: next token is inner sig, then the value(s).
			inner="${_dbus_tokens[_dbus_tok_idx]}"
			(( _dbus_tok_idx++ ))
			local sub
			while IFS= read -r sub; do
				_dbus::emit_one "$sub"
			done < <(_dbus::split_sig "$inner")
			;;
		*)
			echo "_dbus::emit_one: unsupported type '$type'" >&2
			# Best effort: emit the current token raw and advance one.
			printf '%s\n' "${_dbus_tokens[_dbus_tok_idx]:-}"
			(( _dbus_tok_idx++ ))
			;;
	esac
}

# Parse a single line of busctl '<sig> <values>' output and print bare values
# one per line. Reads from stdin or from the argument.
# Usage:
#   dbus::call ... | dbus::fromsig
#   dbus::fromsig 's "hello"'
dbus::fromsig() {
	local line="${1:-}"
	if [[ -z "$line" ]]; then
		IFS= read -r line
	fi
	[[ -z "$line" ]] && return 0

	# Pull leading sig token.
	local sig rest
	sig="${line%% *}"
	if [[ "$sig" == "$line" ]]; then
		# Sig with no values (e.g. empty return).
		return 0
	fi
	rest="${line#* }"

	# Tokenize the value buffer (NUL-separated, since values may contain
	# embedded newlines from resolved \n escapes).
	local _dbus_tokens=() _dbus_tok_idx=0
	mapfile -d '' -t _dbus_tokens < <(_dbus::tokenize_values "$rest")

	# Walk top-level types.
	local type
	while IFS= read -r type; do
		_dbus::emit_one "$type"
	done < <(_dbus::split_sig "$sig")
}

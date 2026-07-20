#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2086  # $_flag is intentionally unquoted: empty for system scope, "--user" for user scope. Word splitting is desired.
# ext/systemd/systemd.sh — bash-framehead systemd client
#
# Wraps systemctl / journalctl / loginctl / timedatectl / hostnamectl /
# machinectl / systemd-run / systemd-analyze into a uniform namespaced API.
# Linux + systemd only.
#
# CONFIGURATION:
#   _SYSTEMD_DEFAULT_SCOPE   "system" (default) or "user". Toggled via
#                            systemd::scope::set. Affects --user flag on
#                            unit / journal / run calls.
#   _SYSTEMD_OUTPUT          "short" (default) | "json" | "pretty". Output
#                            format hint for read calls that support it.
#
# NAMING CONVENTIONS:
#   - Predicates:   is_/has_ snake_case (isactive, isfailed, ismasked, ...)
#   - Pure verbs:   single word (start, stop, reload, mask, revert, ...)
#   - Compounds:    camelCase, no prefix (enablenow, daemonreload, localrtc)
#   - Reads:        bare noun (timezone, chassis, ntp, sessions, ...)
#   - Writes:       set + noun, camelcased (settimezone, setchassis, ...)
#   - Dropped:      with_/on_ prefixes (use ::subns or the systemd term
#                   directly, e.g. systemd::run::onCalendar for OnCalendar=)
#
# EXAMPLE:
#   source bash-framehead.sh
#   source ext/systemd/systemd.sh
#   systemd::version                           # -> 260
#   systemd::hostname::get                     # -> myhost
#   systemd::services::start nginx             # auto-suffixes .service via systemctl
#   systemd::journal::follow nginx --since 1h  # tail a unit's log

# --- Guard ---

declare -f 'runtime::bash_version' &>/dev/null || {
	echo "${BASH_SOURCE[0]}: runtime not found — source bash-framehead.sh first" >&2
	return 1
}

_guard_core_deps=()
_guard_ext_deps=(systemctl)

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

unset _guard_core_deps _guard_ext_deps _guard_dep
# --- end guard ---

# --- Backend detection ---

# Major systemd version (e.g. 256, 260). Empty if undetectable.
_SYSTEMD_VERSION_RAW=$(systemctl --version 2>/dev/null | head -n1 || true)
if [[ "$_SYSTEMD_VERSION_RAW" =~ systemd[[:space:]]+([0-9]+) ]]; then
	_SYSTEMD_VERSION="${BASH_REMATCH[1]}"
else
	_SYSTEMD_VERSION=""
fi
unset _SYSTEMD_VERSION_RAW
readonly _SYSTEMD_VERSION

# Per-tool availability is checked at call time via runtime::has_command
# (matches the convention in src/process.sh:378 etc.). We deliberately do
# not pre-probe at source time — static flags go stale if the user installs
# a new tool mid-session, and runtime::has_command already exists.

# --- Constants ---

_SYSTEMD_DEFAULT_SCOPE="${_SYSTEMD_DEFAULT_SCOPE:-system}"
_SYSTEMD_OUTPUT="${_SYSTEMD_OUTPUT:-short}"

# --- Internal helpers ---

# Echo the systemctl flag for the current scope (--user for user, "" for system).
_systemd::scope_flag() {
	case "$_SYSTEMD_DEFAULT_SCOPE" in
		user)   echo "--user" ;;
		system) echo "" ;;
		*)
			echo "_systemd::scope_flag: bad scope '$_SYSTEMD_DEFAULT_SCOPE'" >&2
			return 1
			;;
	esac
}

# --- Cross-cutting ---

# Echo the major systemd version detected at source time. Empty if
# systemctl --version was unreadable.
# Usage: systemd::version
systemd::version() {
	echo "$_SYSTEMD_VERSION"
}

# Echo the system machine-id (from /etc/machine-id or systemd-machine-id-setup).
# Usage: systemd::machineid
systemd::machineid() {
	cat /etc/machine-id 2>/dev/null
}

# Echo the current boot id. Empty if not readable.
# Usage: systemd::bootid
systemd::bootid() {
	cat /proc/sys/kernel/random/boot_id 2>/dev/null
}

# Echo the current user's uid (numeric).
# Usage: systemd::userid
systemd::userid() {
	id -u 2>/dev/null
}

# Dump a single JSON blob combining hostnamectl + timedatectl + system state.
# Useful as a one-shot "tell me about the host" probe.
# Usage: systemd::info
systemd::info() {
	runtime::has_command hostnamectl || {
		echo "systemd::info: requires hostnamectl" >&2
		return 1
	}
	hostnamectl --json=short 2>/dev/null
}

# --- Scope (system / user instance switcher) ---

# Echo the current default scope ("system" or "user").
# Usage: systemd::scope::get
systemd::scope::get() {
	echo "$_SYSTEMD_DEFAULT_SCOPE"
}

# Set the default scope for subsequent unit / journal / run calls.
# Usage: systemd::scope::set <system|user>
systemd::scope::set() {
	case "$1" in
		system|user) _SYSTEMD_DEFAULT_SCOPE="$1" ;;
		*) echo "systemd::scope::set: expected 'system' or 'user', got '$1'" >&2; return 1 ;;
	esac
}

# Return 0 if scope is "user", 1 otherwise.
# Usage: systemd::scope::isuser
systemd::scope::isuser() {
	[[ "$_SYSTEMD_DEFAULT_SCOPE" == "user" ]]
}

# Return 0 if scope is "system", 1 otherwise.
# Usage: systemd::scope::issystem
systemd::scope::issystem() {
	[[ "$_SYSTEMD_DEFAULT_SCOPE" == "system" ]]
}

# --- Unit (generic; caller supplies full unit name) ---

# List active units. Filters by unit-pattern if given. One unit per line.
# Usage: systemd::unit::list [pattern...]
systemd::unit::list() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl list-units $_flag --no-pager --no-legend --all -- "$@" 2>/dev/null \
		| awk 'NF >= 4 {print $1}'
}

# List all loaded units (incl. inactive). Filters by unit-pattern if given.
# One unit per line.
# Usage: systemd::unit::listloaded [pattern...]
systemd::unit::listloaded() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl list-units $_flag --no-pager --no-legend --all -- "$@" 2>/dev/null \
		| awk 'NF >= 4 {print $1}'
}

# List unit files with their enablement state. One "<unit> <state>" per line.
# Usage: systemd::unit::listfiles [pattern...]
systemd::unit::listfiles() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl list-unit-files $_flag --no-pager --no-legend -- "$@" 2>/dev/null
}

# Return 0 if the unit exists in the given scope, 1 otherwise.
# Usage: systemd::unit::exists <unit>
systemd::unit::exists() {
	local _flag _unit="$1"
	[[ "$_unit" == *.* ]] || _unit="$_unit.service"
	_flag=$(_systemd::scope_flag) || return 1
	systemctl list-unit-files $_flag --no-pager --no-legend -- "$_unit" 2>/dev/null \
		| awk '{print $1}' | grep -Fxq -- "$_unit"
}

# Return 0 if the unit is active.
# Usage: systemd::unit::isactive <unit>
systemd::unit::isactive() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl is-active $_flag --quiet -- "$1"
}

# Return 0 if the unit is in a failed state.
# Usage: systemd::unit::isfailed <unit>
systemd::unit::isfailed() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl is-failed $_flag --quiet -- "$1"
}

# Return 0 if the unit is enabled.
# Usage: systemd::unit::isenabled <unit>
systemd::unit::isenabled() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl is-enabled $_flag --quiet -- "$1"
}

# Return 0 if the unit is masked.
# Usage: systemd::unit::ismasked <unit>
systemd::unit::ismasked() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl is-masked $_flag --quiet -- "$1"
}

# Return 0 if the name matches a template pattern (*@.suffix).
# Usage: systemd::unit::istemplate <name>
systemd::unit::istemplate() {
	[[ "$1" == *@.* ]]
}

# Return 0 if the name matches an instance pattern (foo@bar.suffix).
# Usage: systemd::unit::isinstance <name>
systemd::unit::isinstance() {
	[[ "$1" =~ ^[^@/@]+@[^.@]+\.[^.]+$ ]]
}

# Extract the template from an instance name. foo@bar.service -> foo@.service.
# Errors if input is not an instance.
# Usage: systemd::unit::template <instance>
systemd::unit::template() {
	local _name="$1"
	if [[ "$_name" =~ ^(.+)@(.+)\.([^.]+)$ ]]; then
		echo "${BASH_REMATCH[1]}@.${BASH_REMATCH[3]}"
	elif [[ "$_name" =~ ^(.+)@(.+)$ ]]; then
		echo "${BASH_REMATCH[1]}@"
	else
		echo "systemd::unit::template: '$_name' is not an instance" >&2
		return 1
	fi
}

# Resolve a template + name to a fully qualified instance. foo@.service + bar
# -> foo@bar.service. Errors if template is not a template.
# Usage: systemd::unit::instance <template> <name>
systemd::unit::instance() {
	local _tmpl="$1" _name="$2"
	if [[ "$_tmpl" =~ ^(.+)@\.([^.]+)$ ]]; then
		echo "${BASH_REMATCH[1]}@${_name}.${BASH_REMATCH[2]}"
	elif [[ "$_tmpl" =~ ^(.+)@$ ]]; then
		echo "${BASH_REMATCH[1]}${_name}"
	else
		echo "systemd::unit::instance: '$_tmpl' is not a template" >&2
		return 1
	fi
}

# List all instances of a template. foo@.service -> foo@*.service.
# Usage: systemd::unit::instances <template>
systemd::unit::instances() {
	local _tmpl="$1"
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	if [[ "$_tmpl" =~ ^(.+)@\.([^.]+)$ ]]; then
		local _prefix="${BASH_REMATCH[1]}@" _suffix=".${BASH_REMATCH[2]}"
		systemctl list-units $_flag --no-pager --no-legend --all \
			-- "${_prefix}*${_suffix}" 2>/dev/null \
			| awk -v p="$_prefix" -v s="$_suffix" 'NF >= 4 {
				n = $1
				if (index(n, p) == 1 && index(n, s) == length(n) - length(s) + 1) print n
			}'
	elif [[ "$_tmpl" =~ ^(.+)@$ ]]; then
		local _prefix="${BASH_REMATCH[1]}"
		systemctl list-units $_flag --no-pager --no-legend --all \
			-- "${_prefix}*" 2>/dev/null \
			| awk -v p="$_prefix" 'NF >= 4 && index($1, p) == 1 {print $1}'
	else
		echo "systemd::unit::instances: '$_tmpl' is not a template" >&2
		return 1
	fi
}

# Start one or more units.
# Usage: systemd::unit::start <unit> [unit...]
systemd::unit::start() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl start $_flag --no-ask-password -- "$@"
}

# Stop one or more units.
# Usage: systemd::unit::stop <unit> [unit...]
systemd::unit::stop() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl stop $_flag --no-ask-password -- "$@"
}

# Restart one or more units.
# Usage: systemd::unit::restart <unit> [unit...]
systemd::unit::restart() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl restart $_flag --no-ask-password -- "$@"
}

# Restart a unit only if it's currently active. No-op for inactive units.
# Usage: systemd::unit::tryrestart <unit> [unit...]
systemd::unit::tryrestart() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl try-restart $_flag --no-ask-password -- "$@"
}

# Reload configuration of one or more units (no-op if unit has no reload logic).
# Usage: systemd::unit::reload <unit> [unit...]
systemd::unit::reload() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl reload $_flag --no-ask-password -- "$@"
}

# Reload if possible, otherwise restart. Convenience for "do the right thing".
# Usage: systemd::unit::reloadorrestart <unit> [unit...]
systemd::unit::reloadorrestart() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl reload-or-restart $_flag --no-ask-password -- "$@"
}

# Enable one or more units at boot.
# Usage: systemd::unit::enable <unit> [unit...]
systemd::unit::enable() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl enable $_flag --no-ask-password -- "$@"
}

# Disable one or more units at boot.
# Usage: systemd::unit::disable <unit> [unit...]
systemd::unit::disable() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl disable $_flag --no-ask-password -- "$@"
}

# Enable AND start one or more units in a single call.
# Usage: systemd::unit::enablenow <unit> [unit...]
systemd::unit::enablenow() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl enable $_flag --now --no-ask-password -- "$@"
}

# Disable AND stop one or more units in a single call.
# Usage: systemd::unit::disablenow <unit> [unit...]
systemd::unit::disablenow() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl disable $_flag --now --no-ask-password -- "$@"
}

# Mask one or more units (link to /dev/null, prevent any start).
# Usage: systemd::unit::mask <unit> [unit...]
systemd::unit::mask() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl mask $_flag --no-ask-password -- "$@"
}

# Unmask one or more units.
# Usage: systemd::unit::unmask <unit> [unit...]
systemd::unit::unmask() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl unmask $_flag --no-ask-password -- "$@"
}

# Send a signal to a unit's cgroup. Default signal: SIGTERM.
# Usage: systemd::unit::kill <unit> [signal]
systemd::unit::kill() {
	local _unit="$1" _signal="${2:-}"
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	if [[ -n "$_signal" ]]; then
		# shellcheck disable=SC2086
		systemctl kill $_flag --signal="$_signal" -- "$_unit"
	else
		# shellcheck disable=SC2086
		systemctl kill $_flag -- "$_unit"
	fi
}

# Revert a unit to its vendor-shipped state (drops all overrides).
# Usage: systemd::unit::revert <unit> [unit...]
systemd::unit::revert() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl revert $_flag --no-ask-password -- "$@"
}

# Reload systemd manager configuration. Picks up new/edited unit files.
# Usage: systemd::unit::daemonreload
systemd::unit::daemonreload() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemctl daemon-reload $_flag
}

# Concatenate the unit file and any drop-ins to stdout.
# Usage: systemd::unit::cat <unit>
systemd::unit::cat() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl cat $_flag --no-pager -- "$1" 2>/dev/null
}

# Show a single property's value for a unit. Aliases field().
# Usage: systemd::unit::show <unit> <property>
systemd::unit::show() {
	local _unit="$1" _field="$2"
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	if [[ -n "$_field" ]]; then
		systemctl show $_flag --no-pager --property="$_field" --value -- "$_unit" 2>/dev/null
	else
		systemctl show $_flag --no-pager -- "$_unit" 2>/dev/null
	fi
}

# Synonym for show(). Kept for grep-ability alongside services::field().
# Usage: systemd::unit::field <unit> <property>
systemd::unit::field() {
	systemd::unit::show "$@"
}

# Echo the main PID of a unit (empty if not running or not a service).
# Usage: systemd::unit::pid <unit>
systemd::unit::pid() {
	local _pid
	_pid=$(systemd::unit::show "$1" MainPID 2>/dev/null)
	[[ "$_pid" =~ ^[0-9]+$ ]] && echo "$_pid"
}

# Human-readable status block. Use statusjson() for structured output.
# Usage: systemd::unit::status <unit>
systemd::unit::status() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	systemctl status $_flag --no-pager --full -- "$1" 2>/dev/null
}

# Structured status as JSON (systemd 256+). Falls back to a key=value dump
# on older systems.
# Usage: systemd::unit::statusjson <unit>
systemd::unit::statusjson() {
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	if (( _SYSTEMD_VERSION >= 256 )); then
		systemctl show $_flag --no-pager --output=json -- "$1" 2>/dev/null
	else
		systemctl show $_flag --no-pager -- "$1" 2>/dev/null
	fi
}

# --- Services (.service typed sugar; pure pass-through to systemd::unit) ---
#
# No auto-suffix logic: systemctl already appends .service if missing. This
# namespace is discoverability sugar — operations on `.service` units grouped
# under a dedicated name. Every function delegates to the corresponding
# systemd::unit::*.

systemd::services::start()            { systemd::unit::start "$@"; }
systemd::services::stop()             { systemd::unit::stop "$@"; }
systemd::services::restart()          { systemd::unit::restart "$@"; }
systemd::services::tryrestart()       { systemd::unit::tryrestart "$@"; }
systemd::services::reload()           { systemd::unit::reload "$@"; }
systemd::services::reloadorrestart()  { systemd::unit::reloadorrestart "$@"; }
systemd::services::enable()           { systemd::unit::enable "$@"; }
systemd::services::disable()          { systemd::unit::disable "$@"; }
systemd::services::enablenow()        { systemd::unit::enablenow "$@"; }
systemd::services::disablenow()       { systemd::unit::disablenow "$@"; }
systemd::services::mask()             { systemd::unit::mask "$@"; }
systemd::services::unmask()           { systemd::unit::unmask "$@"; }
systemd::services::kill()             { systemd::unit::kill "$@"; }

systemd::services::exists()           { systemd::unit::exists "$@"; }
systemd::services::isactive()         { systemd::unit::isactive "$@"; }
systemd::services::isfailed()         { systemd::unit::isfailed "$@"; }
systemd::services::isenabled()        { systemd::unit::isenabled "$@"; }
systemd::services::ismasked()         { systemd::unit::ismasked "$@"; }

systemd::services::status()           { systemd::unit::status "$@"; }
systemd::services::statusjson()       { systemd::unit::statusjson "$@"; }
systemd::services::field()            { systemd::unit::field "$@"; }

# --- Journal ---
#
# read / follow are the workhorses; the rest are single-filter convenience
# wrappers that compose with read's tail args. `until` would collide with the
# Bash reserved word, so it's renamed to `untilnow` (compound, same shape as
# enablenow / disablenow / suspendthenhibernate).

systemd::journal::read() { journalctl --no-pager "$@"; }
systemd::journal::follow() { journalctl --no-pager -f "$@"; }
systemd::journal::unit() { journalctl --no-pager -u "$1" "${@:2}"; }
systemd::journal::since() { journalctl --no-pager --since "$1" "${@:2}"; }
systemd::journal::untilnow() { journalctl --no-pager --until "$1" "${@:2}"; }
systemd::journal::priority() { journalctl --no-pager -p "$1" "${@:2}"; }
systemd::journal::grep() { journalctl --no-pager --grep "$1" "${@:2}"; }
systemd::journal::boot() { journalctl --no-pager -b "$1" "${@:2}"; }
systemd::journal::cursor() { journalctl --no-pager --cursor "$1" "${@:2}"; }
systemd::journal::boots() { journalctl --no-pager --list-boots; }
systemd::journal::diskusage() { journalctl --no-pager --disk-usage; }
systemd::journal::verify() { journalctl --verify; }

# --- Analyze ---

# Show units ordered by how much they delayed boot. Optional pattern filter.
# Usage: systemd::analyze::blame [pattern...]
systemd::analyze::blame() {
	runtime::has_command systemd-analyze || {
		echo "systemd::analyze::blame: requires systemd-analyze" >&2
		return 1
	}
	systemd-analyze blame --no-pager "$@" 2>/dev/null
}

# Show the critical chain at boot, or for a specific unit.
# Usage: systemd::analyze::criticalchain [unit]
systemd::analyze::criticalchain() {
	runtime::has_command systemd-analyze || {
		echo "systemd::analyze::criticalchain: requires systemd-analyze" >&2
		return 1
	}
	systemd-analyze critical-chain --no-pager "$@" 2>/dev/null
}

# Verify a unit file's syntax.
# Usage: systemd::analyze::verify <unit-file>
systemd::analyze::verify() {
	runtime::has_command systemd-analyze || {
		echo "systemd::analyze::verify: requires systemd-analyze" >&2
		return 1
	}
	systemd-analyze verify "$@" 2>/dev/null
}

# --- Timedate ---

# Echo the current timezone (e.g. "Europe/Berlin").
# Usage: systemd::timedate::timezone
systemd::timedate::timezone() {
	runtime::has_command timedatectl || {
		echo "systemd::timedate::timezone: requires timedatectl" >&2
		return 1
	}
	timedatectl --no-pager show -p Timezone --value 2>/dev/null
}

# Set the system timezone. Requires root/policy.
# Usage: systemd::timedate::settimezone <tz>
systemd::timedate::settimezone() {
	runtime::has_command timedatectl || {
		echo "systemd::timedate::settimezone: requires timedatectl" >&2
		return 1
	}
	timedatectl set-timezone "$@"
}

# Echo the current system time (RFC 3339 / ISO 8601 with offset).
# Usage: systemd::timedate::time
systemd::timedate::time() {
	runtime::has_command timedatectl || {
		echo "systemd::timedate::time: requires timedatectl" >&2
		return 1
	}
	timedatectl --no-pager show -p Time --value 2>/dev/null
}

# Set the system time. Requires root. Format: "YYYY-MM-DD HH:MM:SS" or epoch.
# Usage: systemd::timedate::settime <time>
systemd::timedate::settime() {
	runtime::has_command timedatectl || {
		echo "systemd::timedate::settime: requires timedatectl" >&2
		return 1
	}
	timedatectl set-time "$@"
}

# Echo NTP synchronization state ("yes" or "no").
# Usage: systemd::timedate::ntp
systemd::timedate::ntp() {
	runtime::has_command timedatectl || {
		echo "systemd::timedate::ntp: requires timedatectl" >&2
		return 1
	}
	timedatectl --no-pager show -p NTP --value 2>/dev/null
}

# Enable or disable NTP synchronization. Requires root.
# Usage: systemd::timedate::setntp <0|1>
systemd::timedate::setntp() {
	runtime::has_command timedatectl || {
		echo "systemd::timedate::setntp: requires timedatectl" >&2
		return 1
	}
	timedatectl set-ntp "$@"
}

# Echo whether the RTC is in local time ("yes" or "no").
# Usage: systemd::timedate::localrtc
systemd::timedate::localrtc() {
	runtime::has_command timedatectl || {
		echo "systemd::timedate::localrtc: requires timedatectl" >&2
		return 1
	}
	timedatectl --no-pager show -p LocalRTC --value 2>/dev/null
}

# Set RTC to local time (1) or UTC (0). Requires root.
# Usage: systemd::timedate::setlocalrtc <0|1>
systemd::timedate::setlocalrtc() {
	runtime::has_command timedatectl || {
		echo "systemd::timedate::setlocalrtc: requires timedatectl" >&2
		return 1
	}
	timedatectl set-local-rtc "$@"
}

# --- Hostname ---
#
# Two compat notes:
# 1. hostnamectl's `show` subcommand was added in systemd 252; older builds
#    only support per-field subcommands (hostname, chassis, icon-name,
#    deployment). We use the subcommand form throughout for compatibility.
# 2. --no-pager is intentionally NOT used here: some older hostnamectl
#    builds reject it. The per-field subcommands don't paginate anyway.

# Echo the system hostname.
# Usage: systemd::hostname::get
systemd::hostname::get() {
	runtime::has_command hostnamectl || {
		echo "systemd::hostname::get: requires hostnamectl" >&2
		return 1
	}
	hostnamectl hostname 2>/dev/null
}

# Set the system hostname. Requires root.
# Usage: systemd::hostname::set <hostname>
systemd::hostname::set() {
	runtime::has_command hostnamectl || {
		echo "systemd::hostname::set: requires hostnamectl" >&2
		return 1
	}
	hostnamectl set-hostname "$@"
}

# Echo the chassis type (desktop / laptop / server / vm / container / ...).
# Usage: systemd::hostname::chassis
systemd::hostname::chassis() {
	runtime::has_command hostnamectl || {
		echo "systemd::hostname::chassis: requires hostnamectl" >&2
		return 1
	}
	hostnamectl chassis 2>/dev/null
}

# Set chassis type. Requires root.
# Usage: systemd::hostname::setchassis <chassis>
systemd::hostname::setchassis() {
	runtime::has_command hostnamectl || {
		echo "systemd::hostname::setchassis: requires hostnamectl" >&2
		return 1
	}
	hostnamectl set-chassis "$@"
}

# Echo the chassis icon name.
# Usage: systemd::hostname::icon
systemd::hostname::icon() {
	runtime::has_command hostnamectl || {
		echo "systemd::hostname::icon: requires hostnamectl" >&2
		return 1
	}
	hostnamectl icon-name 2>/dev/null
}

# Set chassis icon name. Requires root.
# Usage: systemd::hostname::seticon <icon>
systemd::hostname::seticon() {
	runtime::has_command hostnamectl || {
		echo "systemd::hostname::seticon: requires hostnamectl" >&2
		return 1
	}
	hostnamectl set-icon-name "$@"
}

# Echo the deployment environment.
# Usage: systemd::hostname::deployment
systemd::hostname::deployment() {
	runtime::has_command hostnamectl || {
		echo "systemd::hostname::deployment: requires hostnamectl" >&2
		return 1
	}
	hostnamectl deployment 2>/dev/null
}

# Set deployment environment. Requires root.
# Usage: systemd::hostname::setdeployment <env>
systemd::hostname::setdeployment() {
	runtime::has_command hostnamectl || {
		echo "systemd::hostname::setdeployment: requires hostnamectl" >&2
		return 1
	}
	hostnamectl set-deployment "$@"
}

# --- Login (sessions, seats, users, power actions) ---

# List session IDs, one per line.
# Usage: systemd::login::sessions
systemd::login::sessions() {
	runtime::has_command loginctl || {
		echo "systemd::login::sessions: requires loginctl" >&2
		return 1
	}
	loginctl --no-pager list-sessions --no-legend 2>/dev/null | awk '{print $1}'
}

# Show session status as JSON.
# Usage: systemd::login::sessioninfo <id>
systemd::login::sessioninfo() {
	runtime::has_command loginctl || {
		echo "systemd::login::sessioninfo: requires loginctl" >&2
		return 1
	}
	loginctl --no-pager show-session --json=short "$@" 2>/dev/null
}

# List user IDs, one per line.
# Usage: systemd::login::users
systemd::login::users() {
	runtime::has_command loginctl || {
		echo "systemd::login::users: requires loginctl" >&2
		return 1
	}
	loginctl --no-pager list-users --no-legend 2>/dev/null | awk '{print $1}'
}

# List seat names, one per line.
# Usage: systemd::login::seats
systemd::login::seats() {
	runtime::has_command loginctl || {
		echo "systemd::login::seats: requires loginctl" >&2
		return 1
	}
	loginctl --no-pager list-seats --no-legend 2>/dev/null | awk '{print $1}'
}

# Echo the current session ID (XDG_SESSION_ID or XDG_SESSION_ID env /proc).
# Usage: systemd::login::mysession
systemd::login::mysession() {
	if [[ -n "${XDG_SESSION_ID:-}" ]]; then
		echo "$XDG_SESSION_ID"
	elif [[ -r /run/systemd/users/"$(id -u)" ]] || [[ -d /run/systemd/sessions ]]; then
	local _uid
	_uid=$(id -u 2>/dev/null) || return 1
	# First session belonging to this user, alphabetically
	find /run/systemd/sessions -maxdepth 1 -type f 2>/dev/null \
		| while read -r _f; do
			local _sess _sess_uid
			_sess=$(basename "$_f")
			_sess_uid=$(awk -F= '/^UID=/{print $2}' "$_f" 2>/dev/null)
			if [[ "$_sess_uid" == "$_uid" ]]; then
				echo "$_sess"
				break
			fi
		done | head -n1
fi
}

# Lock one or more sessions. With no argument, locks the caller's session.
# Usage: systemd::login::locksession [id...]
systemd::login::locksession() {
	runtime::has_command loginctl || {
		echo "systemd::login::locksession: requires loginctl" >&2
		return 1
	}
	if (( $# == 0 )); then
		loginctl --no-pager lock-sessions
	else
		loginctl --no-pager lock-session "$@"
	fi
}

# Terminate one or more sessions. Requires policy/permission.
# Usage: systemd::login::terminatesession <id...>
systemd::login::terminatesession() {
	runtime::has_command loginctl || {
		echo "systemd::login::terminatesession: requires loginctl" >&2
		return 1
	}
	loginctl --no-pager terminate-session "$@"
}

# Power actions. All require appropriate policy. Names use camelcase
# compounds to match the rest of the API (hybridsleep,
# suspendthenhibernate).
# Usage: systemd::login::suspend
systemd::login::suspend() {
	runtime::has_command loginctl || { echo "systemd::login::suspend: requires loginctl" >&2; return 1; }
	loginctl --no-pager suspend "$@"
}

# Usage: systemd::login::hibernate
systemd::login::hibernate() {
	runtime::has_command loginctl || { echo "systemd::login::hibernate: requires loginctl" >&2; return 1; }
	loginctl --no-pager hibernate "$@"
}

# Usage: systemd::login::hybridsleep
systemd::login::hybridsleep() {
	runtime::has_command loginctl || { echo "systemd::login::hybridsleep: requires loginctl" >&2; return 1; }
	loginctl --no-pager hybrid-sleep "$@"
}

# Usage: systemd::login::suspendthenhibernate
systemd::login::suspendthenhibernate() {
	runtime::has_command loginctl || { echo "systemd::login::suspendthenhibernate: requires loginctl" >&2; return 1; }
	loginctl --no-pager suspend-then-hibernate "$@"
}

# Usage: systemd::login::poweroff
systemd::login::poweroff() {
	runtime::has_command loginctl || { echo "systemd::login::poweroff: requires loginctl" >&2; return 1; }
	loginctl --no-pager poweroff "$@"
}

# Usage: systemd::login::reboot
systemd::login::reboot() {
	runtime::has_command loginctl || { echo "systemd::login::reboot: requires loginctl" >&2; return 1; }
	loginctl --no-pager reboot "$@"
}

# Usage: systemd::login::halt
systemd::login::halt() {
	runtime::has_command loginctl || { echo "systemd::login::halt: requires loginctl" >&2; return 1; }
	loginctl --no-pager halt "$@"
}

# --- Machine (containers, VMs, hosts) ---

# List running VMs and containers, one per line.
# Usage: systemd::machine::list
systemd::machine::list() {
	runtime::has_command machinectl || {
		echo "systemd::machine::list: requires machinectl" >&2
		return 1
	}
	machinectl --no-pager list --no-legend 2>/dev/null | awk '{print $1}'
}

# Show machine status.
# Usage: systemd::machine::status <name>
systemd::machine::status() {
	runtime::has_command machinectl || {
		echo "systemd::machine::status: requires machinectl" >&2
		return 1
	}
	machinectl --no-pager status "$@"
}

# Start a container (as a service).
# Usage: systemd::machine::start <name>
systemd::machine::start() {
	runtime::has_command machinectl || {
		echo "systemd::machine::start: requires machinectl" >&2
		return 1
	}
	machinectl --no-pager start "$@"
}

# Power off one or more containers. Requires policy.
# Usage: systemd::machine::poweroff <name...>
systemd::machine::poweroff() {
	runtime::has_command machinectl || {
		echo "systemd::machine::poweroff: requires machinectl" >&2
		return 1
	}
	machinectl --no-pager poweroff "$@"
}

# Reboot one or more containers. Requires policy.
# Usage: systemd::machine::reboot <name...>
systemd::machine::reboot() {
	runtime::has_command machinectl || {
		echo "systemd::machine::reboot: requires machinectl" >&2
		return 1
	}
	machinectl --no-pager reboot "$@"
}

# Terminate (force kill) one or more VMs/containers. Requires policy.
# Usage: systemd::machine::terminate <name...>
systemd::machine::terminate() {
	runtime::has_command machinectl || {
		echo "systemd::machine::terminate: requires machinectl" >&2
		return 1
	}
	machinectl --no-pager terminate "$@"
}

# Send a signal to a machine's processes. Default signal: SIGTERM.
# Usage: systemd::machine::kill <name> [signal]
systemd::machine::kill() {
	local _name="$1" _signal="${2:-}"
	runtime::has_command machinectl || {
		echo "systemd::machine::kill: requires machinectl" >&2
		return 1
	}
	if [[ -n "$_signal" ]]; then
		machinectl --no-pager kill --signal="$_signal" -- "$_name"
	else
		machinectl --no-pager kill -- "$_name"
	fi
}

# Run a shell (or other command) in a container/host. Errors if no TTY
# is attached and no command is given.
# Usage: systemd::machine::shell <name> [cmd...]
systemd::machine::shell() {
	runtime::has_command machinectl || {
		echo "systemd::machine::shell: requires machinectl" >&2
		return 1
	}
	if [[ $# -eq 1 ]] && [[ ! -t 0 ]]; then
		echo "systemd::machine::shell: no command given and stdin is not a TTY" >&2
		return 1
	fi
	machinectl --no-pager shell "$@"
}

# Get a login prompt in a container. Errors if no TTY is attached.
# Usage: systemd::machine::login <name>
systemd::machine::login() {
	runtime::has_command machinectl || {
		echo "systemd::machine::login: requires machinectl" >&2
		return 1
	}
	if [[ ! -t 0 ]]; then
		echo "systemd::machine::login: requires an attached TTY" >&2
		return 1
	fi
	machinectl --no-pager login "$@"
}

# --- Run (transient units) ---
#
# Conventions for the helper functions (properties / slice / env / onCalendar):
#   systemd::run::service <cmd...>           # base: run a command as a transient service
#   systemd::run::scope   <cmd...>           # run as a transient scope (no exec)
#   systemd::run::wait    <unit>             # block until a unit finishes
#   systemd::run::properties <kv-list> <cmd> # first arg: space-separated "K=V K=V"
#   systemd::run::slice    <slice>    <cmd>  # first arg: slice name
#   systemd::run::env      <kv-list>  <cmd>  # first arg: space-separated "K=V K=V"
#   systemd::run::onCalendar <spec>   <cmd>  # first arg: calendar spec
#   systemd::run::timer    <spec>     <cmd>  # alias for onCalendar
#   systemd::run::limits   <kv-list>  <cmd>  # alias for properties (named for grep)

# Run a command as a transient service unit. systemd generates a unit name
# by default; pass --unit=NAME to choose. The transient unit is auto-collected
# on exit unless --remain-after-exit is set.
# Usage: systemd::run::service [systemd-run-flags...] <cmd> [arg...]
systemd::run::service() {
	runtime::has_command systemd-run || {
		echo "systemd::run::service: requires systemd-run" >&2
		return 1
	}
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemd-run $_flag --no-ask-password "$@"
}

# Run as a transient scope (no exec, just cgroup). Use for grouping child
# processes without launching a new service.
# Usage: systemd::run::scope [systemd-run-flags...] <cmd> [arg...]
systemd::run::scope() {
	runtime::has_command systemd-run || {
		echo "systemd::run::scope: requires systemd-run" >&2
		return 1
	}
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemd-run $_flag --scope --no-ask-password "$@"
}

# Run a command as a transient service and block until it finishes. Mirrors
# `systemd-run --wait` semantics. Returns the command's exit code.
# Usage: systemd::run::wait <cmd> [arg...]
systemd::run::wait() {
	runtime::has_command systemd-run || {
		echo "systemd::run::wait: requires systemd-run" >&2
		return 1
	}
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemd-run $_flag --wait --no-ask-password "$@"
}

# Add --property flags from a space-separated K=V list. Quote individual
# values if they contain spaces: `K='v with spaces'`. The command and its
# args follow the kv-list, separated by --.
# Usage: systemd::run::properties <kv-list> -- <cmd> [arg...]
systemd::run::properties() {
	local _props="$1"; shift
	runtime::has_command systemd-run || {
		echo "systemd::run::properties: requires systemd-run" >&2
		return 1
	}
	local _args=() _kv
	# shellcheck disable=SC2206
	for _kv in $_props; do
		_args+=(--property="$_kv")
	done
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemd-run $_flag --no-ask-password "${_args[@]}" "$@"
}

# Pin a command to a specific cgroup slice.
# Usage: systemd::run::slice <slice> -- <cmd> [arg...]
systemd::run::slice() {
	local _slice="$1"; shift
	runtime::has_command systemd-run || {
		echo "systemd::run::slice: requires systemd-run" >&2
		return 1
	}
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemd-run $_flag --slice="$_slice" --no-ask-password "$@"
}

# Set environment variables from a space-separated K=V list.
# Usage: systemd::run::env <kv-list> -- <cmd> [arg...]
systemd::run::env() {
	local _env="$1"; shift
	runtime::has_command systemd-run || {
		echo "systemd::run::env: requires systemd-run" >&2
		return 1
	}
	local _args=() _kv
	# shellcheck disable=SC2206
	for _kv in $_env; do
		_args+=(--setenv="$_kv")
	done
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemd-run $_flag --no-ask-password "${_args[@]}" "$@"
}

# Schedule a command for a specific calendar time. Creates a transient
# timer + service pair.
# Usage: systemd::run::onCalendar <spec> -- <cmd> [arg...]
systemd::run::onCalendar() {
	local _spec="$1"; shift
	runtime::has_command systemd-run || {
		echo "systemd::run::onCalendar: requires systemd-run" >&2
		return 1
	}
	local _flag
	_flag=$(_systemd::scope_flag) || return 1
	# shellcheck disable=SC2086
	systemd-run $_flag --on-calendar="$_spec" --no-ask-password "$@"
}

# Alias for onCalendar. Same semantics.
# Usage: systemd::run::timer <spec> -- <cmd> [arg...]
systemd::run::timer() {
	systemd::run::onCalendar "$@"
}

# Alias for properties. Named for grep-ability: "set rlimits on a run::limits".
# Usage: systemd::run::limits <kv-list> -- <cmd> [arg...]
systemd::run::limits() {
	systemd::run::properties "$@"
}

# --- Adjacent tools (intentional no-op stubs) ---
#
# Each stub is a placeholder for a future expansion. The body intentionally
# does not call the tool — only the runtime::has_command guard and a clear
# "not yet implemented" stderr message. Pass this extension to a new session
# to expand any stub into a proper typed view.
#
# Stub shape:
#   1. Check the binary exists with runtime::has_command
#   2. If missing, emit a clear "requires X" error and return 1
#   3. If present, emit a "stub, not yet implemented" message and return 1
#   4. Future expansion: replace the body between the guard and the return

# STUB: requires systemd-resolve (from systemd-resolved). When implemented,
# should provide structured DNS query/flush/list operations, with --json
# parsing of output where available.
systemd::resolve::call() {
	runtime::has_command systemd-resolve || {
		echo "systemd::resolve::call: requires systemd-resolve" >&2
		return 1
	}
	echo "systemd::resolve::call: stub, not yet implemented" >&2
	return 1
}

# STUB: requires systemd-cryptenroll. When implemented, should expose
# enroll/list/remove operations for LUKS2 storage encryption tokens
# (PKCS#11, FIDO2, TPM2, recovery key).
systemd::cryptenroll::call() {
	runtime::has_command systemd-cryptenroll || {
		echo "systemd::cryptenroll::call: requires systemd-cryptenroll" >&2
		return 1
	}
	echo "systemd::cryptenroll::call: stub, not yet implemented" >&2
	return 1
}

# STUB: requires systemd-creds. When implemented, should expose
# encrypt/decrypt/list operations for the systemd credentials store,
# used for passing secrets to units securely.
systemd::creds::call() {
	runtime::has_command systemd-creds || {
		echo "systemd::creds::call: requires systemd-creds" >&2
		return 1
	}
	echo "systemd::creds::call: stub, not yet implemented" >&2
	return 1
}

# STUB: requires systemd-tmpfiles. When implemented, should provide
# create/remove/clean operations for volatile and persistent runtime
# files, with structured parsing of tmpfiles.d configs.
systemd::tmpfiles::call() {
	runtime::has_command systemd-tmpfiles || {
		echo "systemd::tmpfiles::call: requires systemd-tmpfiles" >&2
		return 1
	}
	echo "systemd::tmpfiles::call: stub, not yet implemented" >&2
	return 1
}

# STUB: requires systemd-sysext. When implemented, should expose
# merge/unmerge/list/refresh operations for system extension images
# that overlay /usr and /opt at runtime.
systemd::sysext::call() {
	runtime::has_command systemd-sysext || {
		echo "systemd::sysext::call: requires systemd-sysext" >&2
		return 1
	}
	echo "systemd::sysext::call: stub, not yet implemented" >&2
	return 1
}

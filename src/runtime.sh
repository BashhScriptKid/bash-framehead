#!/usr/bin/env bash
runtime::is_terminal() {
	# Thorough check for all standard file descriptors (stdin, stdout, stderr)
	[[ -t 0 && -t 1 && -t 2 ]]
}

runtime::is_terminal::stdin() {
	[[ -t 0 ]]
}

runtime::is_terminal::stdout() {
	[[ -t 1 ]]
}

runtime::is_terminal::stderr() {
	[[ -t 2 ]]
}

runtime::is_traced() {
		[[ "$-" == *x* ]] || [[ -n "$BASH_XTRACEFD" ]]
}

runtime::is_verbose() {
		[[ "$-" == *v* ]]
}

runtime::errexit_enabled() {
		[[ "$-" == *e* ]]
}

runtime::nounset_enabled() {
		[[ "$-" == *u* ]]
}

runtime::noclobber_enabled() {
		[[ "$-" == *C* ]]
}

runtime::is_interactive() {
	[[ $- == *i* ]]
}

runtime::has_flag() {
		local flag="$1"
		[[ "$-" == *"$flag"* ]]
}

runtime::is_login() {
	shopt -q login_shell
}

runtime::is_sourced() {
	[[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

runtime::is_bash() {
	[[ -n "$BASH_VERSION" ]]
}

runtime::is_pipe() {
	# Check if stdin is a pipe
	[[ -p /dev/stdin ]] && return 0

	# Check if stdin is redirected from a file
	[[ ! -t 0 ]] && return 0

	# Only check jobs if we're not interactive
	if ! runtime::is_interactive && [[ -n "$(jobs -p)" ]]; then
		return 0
	fi

	return 1
}

runtime::is_redirected() {
	# Check if any std descriptor is redirected
	[[ ! -t 0 ]] || [[ ! -t 1 ]] || [[ ! -t 2 ]]
}

runtime::is_subshell() {
		[[ "$BASH_SUBSHELL" -gt 0 ]]
}

runtime::job_controlled() {
		[[ "$-" == *m* ]]
}

runtime::debug_trapped() {
		[[ -n "$(trap -p DEBUG)" ]]
}

runtime::braceexpand_enabled() {
		[[ "$-" == *B* ]]
}

runtime::histexpand_enabled() {
		[[ "$-" == *H* ]]
}

runtime::physical_cd_enabled() {
		[[ "$-" == *P* ]]
}


runtime::has_command() {
	command -v "$1" >/dev/null 2>&1
}

# Degrade-gracefully sleep wrapper. Silently ignores errors when the
# system sleep lacks sub-second support or is interrupted.
# Usage: runtime::sleep seconds
runtime::sleep() {
	sleep "$1" 2>/dev/null || true
}

runtime::is_root() {
	[[ $EUID -eq 0 ]]
}

runtime::is_desktop() {
	[ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]
}

runtime::de() {
		if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
				echo "none"; return
		fi

		local _session="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-${GDMSESSION:-}}}"
		case "${_session,,}" in
				*gnome*)    echo "gnome";    return ;;
				*kde*)      echo "kde";      return ;;
				*xfce*)     echo "xfce";     return ;;
				*lxqt*)     echo "lxqt";     return ;;
				*lxde*)     echo "lxde";     return ;;
				*mate*)     echo "mate";     return ;;
				*cinnamon*) echo "cinnamon"; return ;;
				*budgie*)   echo "budgie";   return ;;
				*deepin*)   echo "deepin";   return ;;
				*pantheon*) echo "pantheon"; return ;;
				*unity*)    echo "unity";    return ;;
				*cosmic*)   echo "cosmic";   return ;;
		esac

		local -A _procs=(
				[gnome-shell]=gnome   [plasmashell]=kde       [xfce4-session]=xfce
				[lxqt-session]=lxqt   [lxsession]=lxde        [mate-session]=mate
				[cinnamon]=cinnamon   [budgie-daemon]=budgie  [deepin-session]=deepin
				[pantheon]=pantheon   [unity]=unity           [cosmic-session]=cosmic
		)
		local _p
		for _p in "${!_procs[@]}"; do
				pgrep -x "$_p" >/dev/null 2>&1 && echo "${_procs[$_p]}" && return
		done

		# Display present but only a bare WM — let caller query runtime::wm
		local _wm; _wm=$(runtime::wm)
		[[ "$_wm" != "unknown" ]] && echo "wm-only" && return

		echo "unknown"
}

runtime::wm() {
		if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
				echo "none"; return
		fi

		local _session="${XDG_SESSION_DESKTOP:-}"
		case "${_session,,}" in
				*hyprland*) echo "hyprland"; return ;;
				*sway*)     echo "sway";     return ;;
				*wayfire*)  echo "wayfire";  return ;;
				*river*)    echo "river";    return ;;
		esac

		if runtime::has_command xprop && [[ -n "${DISPLAY:-}" ]]; then
				local _wm_name
				_wm_name=$(xprop -root -notype _NET_WM_NAME 2>/dev/null | sed 's/.*= *"//;s/".*//')
				[[ -n "$_wm_name" ]] && echo "${_wm_name,,}" && return
		fi

		local -A _procs=(
				[hyprland]=hyprland       [sway]=sway          [wayfire]=wayfire
				[river]=river             [mutter]=mutter      [kwin_wayland]=kwin
				[kwin_x11]=kwin           [xfwm4]=xfwm4        [openbox]=openbox
				[i3]=i3                   [bspwm]=bspwm        [awesome]=awesome
				[fluxbox]=fluxbox         [icewm]=icewm        [jwm]=jwm
				[qtile]=qtile             [xmonad]=xmonad      [marco]=marco
				[metacity]=metacity       [compiz]=compiz
				[enlightenment]=enlightenment
				[herbstluftwm]=herbstluftwm
		)
		local _p
		for _p in "${!_procs[@]}"; do
				pgrep -x "$_p" >/dev/null 2>&1 && echo "${_procs[$_p]}" && return
		done

		echo "unknown"
}

runtime::is_wayland() { [[ -n "${WAYLAND_DISPLAY:-}" ]]; }
runtime::is_x11()     { [[ -n "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; }

runtime::sysinit() {
	local _pid1
	_pid1=$(ps -p 1 -o comm= 2>/dev/null) || _pid1="unknown"

	case "$_pid1" in
		init | /sbin/init)
			# PID 1 is generic "init" — narrow down the actual init system
			if   [[ -f /sbin/upstart ]]; then echo "upstart"
			elif [[ -d /run/openrc ]];   then echo "openrc"
			elif [[ -d /run/runit ]];    then echo "runit"
			elif [[ -d /run/s6 ]];       then echo "s6"
			else                              echo "sysvinit"
			fi
			;;

		launchd)              echo "launchd" ;;
		systemd)              echo "systemd" ;;
		runit)                echo "runit"   ;;
		s6-svscan)            echo "s6"      ;;
		OpenRC | openrc-init) echo "openrc"  ;;
		daemon)               echo "rc"      ;;
		svc)                  echo "runit"   ;;
		*)                    echo "$_pid1"  ;;
	esac
}

runtime::is_sudo() {
	[[ -n "$SUDO_USER" ]]
}


runtime::is_ci() {
	[[ -n "$CI" ]] ||
		[[ -n "$GITHUB_ACTIONS" ]] ||
		[[ -n "$GITLAB_CI" ]] ||
		[[ -n "$CIRCLECI" ]] ||
		[[ -n "$TRAVIS" ]] ||
		[[ -n "$JENKINS_URL" ]] ||
		[[ -n "$BITBUCKET_BUILD_NUMBER" ]] ||
		[[ -n "$TEAMCITY_VERSION" ]] ||
		[[ -n "$DRONE" ]] ||
		[[ -n "$CODEBUILD_BUILD_ID" ]] ||
		[[ -n "$AZURE_HTTP_USER_AGENT" ]] ||  # Azure DevOps
		[[ -n "$BUILDKITE" ]]  # Buildkite
}

runtime::kernel_version() {
    # Fail if runtime::os is empty or failed
    local os; os=$(runtime::os) || return 1
    [[ -z $os ]] && return 1

    local v
    v=$(uname -r)

    # Extract leading numbers and dots (e.g., "6.8.0" from "6.8.0-rc1-generic")
    if [[ $v =~ ^([0-9]+(\.[0-9]+)+) ]]; then
        printf '%s\n' "${BASH_REMATCH[1]}"
    else
        # Fallback to full string if format is unusual
        printf '%s\n' "$v"
    fi
}

runtime::exec_root() {
	# Already root, nothing to do
	if runtime::is_root; then
		return 0
	fi

	if runtime::has_command sudo; then
		# In a non-terminal context, check if sudo can run without a password prompt
		# -n flag makes sudo fail immediately instead of hanging if password is needed
		if ! runtime::is_terminal && ! sudo -n true 2>/dev/null; then
			echo "runtime::request_root: sudo requires a password but no " \
				"terminal is available, will attempt alternatives." >&2
			# Fall through to other methods
		else
			sudo "$@"
			return $?
		fi
	fi

	if runtime::has_command pkexec && runtime::is_desktop; then
		pkexec "$@"
	elif runtime::has_command doas; then
		doas "$@"
	elif runtime::has_command su; then
		# su -c takes a single string, fragile with spaces in arguments
		su -c "exec $(printf '%q ' "$@")" root
	else
		echo "runtime::request_root: no privilege escalation method found" >&2
		return 1
	fi
}

runtime::is_wsl() {
	[[ -f /proc/version ]] && grep -qi "microsoft" /proc/version
}

runtime::os() {
	if runtime::is_wsl; then
		echo "wsl"
		return
	fi

	case "$(uname -s)" in
	Linux*)  echo "linux"   ;;
	Darwin*) echo "darwin"  ;;
	CYGWIN*) echo "cygwin"  ;;
	MINGW*)  echo "mingw"   ;;
	*)       echo "unknown" ;;
	esac
}

runtime::arch() {
	case "$(uname -m)" in
	x86_64)  echo "amd64"   ;;
	i386)    echo "386"     ;;
	armv7l)  echo "armv7"   ;;
	aarch64) echo "arm64"   ;;
	*)       echo "unknown" ;;
	esac
}

runtime::distro() {
	if [[ -f /etc/os-release ]]; then
		(. /etc/os-release && echo "$ID")
	else
		echo "unknown"
	fi
}

runtime::bash_version() {
	echo "${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}"
}

runtime::bash_version::major() {
	echo "${BASH_VERSINFO[0]}"
}

# Default to 3, assuming that's what's at least needed for this framework (not final)
runtime::is_minimum_bash() {
	((BASH_VERSINFO[0] >= ${1:-3}))
}

# Internal: compare against Bash major.minor version (handles 5.1, 5.2, etc.)
_runtime::min_bash() {
		local _major=${1%.*} _minor=${1#*.}
		(( BASH_VERSINFO[0] > _major || (BASH_VERSINFO[0] == _major && BASH_VERSINFO[1] >= _minor) ))
}

runtime::is_container() {
	[[ -f /.dockerenv ]] ||
	[[ -f /run/.containerenv ]] ||
	grep -q "docker\|lxc\|kubepods" /proc/1/cgroup 2>/dev/null ||
	[[ -n "$CONTAINER" ]] ||
	[[ -n "$KUBERNETES_SERVICE_HOST" ]]
}

runtime::supports_color() {
	# Check if terminal supports color
	[[ -t 1 ]] && [[ "$TERM" != "dumb" ]] && {
		[[ -n "$COLORTERM" ]] ||
		[[ "$TERM" =~ ^(xterm|screen|vt100|linux|ansi) ]] || {
			local colors
			colors=$(tput colors 2>/dev/null)
			[[ -n "$colors" && "$colors" -ge 8 ]]
		}
	}
}


runtime::supports_truecolor() {
	[[ -n "$COLORTERM" ]] && [[ "$COLORTERM" =~ ^(truecolor|24bit) ]]
}

runtime::is_multiplexer() {
	[[ -n "$STY" ]] || [[ -n "$TMUX" ]]
}

runtime::is_tmux() {
	[[ -n "$TMUX" ]]
}

runtime::screen_session() {
	echo "${STY:-${TMUX:-none}}"
}

runtime::is_ssh() {
	[[ -n "$SSH_CLIENT" ]] ||
	[[ -n "$SSH_TTY" ]] ||
	[[ -n "$SSH_CONNECTION" ]]
}

runtime::ssh_client() {
	echo "${SSH_CLIENT%% *}"  # First part is client IP
}

runtime::is_tty() {
	# Check if we have a controlling terminal
	[[ -t 0 ]] && tty -s 2>/dev/null
}

runtime::tty_name() {
	tty 2>/dev/null || echo "not a tty"
}

runtime::is_pty() {
	# Check if we're in a pseudo-terminal
	[[ "$(tty)" =~ ^/dev/pts/[0-9]+ ]]
}


runtime::is_virtualized() {
	if [[ $(runtime::os) == "linux" ]]; then
		if [[ -f /proc/cpuinfo ]]; then
			grep -q "hypervisor" /proc/cpuinfo && return 0
		fi
		if [[ -f /sys/class/dmi/id/product_name ]]; then
			local product
			product=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
			[[ "$product" =~ (VirtualBox|VMware|KVM|QEMU|Xen|Hyper-V) ]] && return 0
		fi
	fi
	return 1
}


runtime::pm() {
    runtime::has_command apt-get      && { echo "apt";    return 0; }
    runtime::has_command pacman       && { echo "pacman"; return 0; }
    runtime::has_command dnf          && { echo "dnf";    return 0; }
    runtime::has_command yum          && { echo "yum";    return 0; }
    runtime::has_command zypper       && { echo "zypper"; return 0; }
    runtime::has_command apk          && { echo "apk";    return 0; }
    runtime::has_command brew         && { echo "brew";   return 0; }
    runtime::has_command pkg          && { echo "pkg";    return 0; }
    runtime::has_command xbps-install && { echo "xbps";   return 0; }
    runtime::has_command nix-env      && { echo "nix";    return 0; }

    echo "unknown"
    return 1
}

# --- COPROC ---

# Start a named coprocess. Stores name in caller's registry.
# Usage: runtime::coproc::start <registry> <name> <command...>
runtime::coproc::start() {
		local -n _registry="$1"; shift
		local _name=$1; shift
		if [[ -z "$_name" ]]; then
				echo "runtime::coproc::start: name required" >&2
				return 1
		fi
		if [[ " ${_registry[*]} " == *" $_name "* ]]; then
				echo "runtime::coproc::start: coproc '$_name' already exists" >&2
				return 1
		fi
		coproc "$_name" { "$@" 2>&1; }
		_registry+=("$_name")
}

# Send data to a coproc's stdin.
# Usage: runtime::coproc::send <name> <data>
runtime::coproc::send() {
		local name=$1 data=$2
		local -n _cs_fd="${name}[1]"
		printf '%s\n' "$data" >&${_cs_fd}
}

# Read one line from a coproc's stdout (blocks until data available).
# Usage: runtime::coproc::read <name>
runtime::coproc::read() {
		local name=$1 line
		local -n _cr_fd="${name}[0]"
		IFS= read -r -t 5 line <&${_cr_fd} || true
		echo "$line"
}

# Read all available output from a coproc (non-blocking).
# Usage: runtime::coproc::read_all <name>
runtime::coproc::read_all() {
		local name=$1 line
		local -n _cra_fd="${name}[0]"
		while IFS= read -r -t 0.1 line <&${_cra_fd} 2>/dev/null; do
				echo "$line"
		done
}

# Return 0 if the named coproc is alive.
# Usage: runtime::coproc::alive <name>
runtime::coproc::alive() {
		local pid; pid=$(runtime::coproc::pid "$1" 2>/dev/null) || return 1
		kill -0 "$pid" 2>/dev/null
}

# Echo the PID of a named coproc.
# Usage: runtime::coproc::pid <name>
runtime::coproc::pid() {
		local -n _cp_var="${1}_PID"
		echo "${_cp_var:-}"
}

# Stop a named coproc (kill process, close fds).
# Usage: runtime::coproc::stop <registry> <name>
runtime::coproc::stop() {
		local -n _registry="$1"; shift
		local _name=$1
		local pid; pid=$(runtime::coproc::pid "$_name" 2>/dev/null) || return 1

		local -n _cs_fd="${_name}[0]" 2>/dev/null && eval "exec ${_cs_fd}<&-" 2>/dev/null
		local -n _cs_fd1="${_name}[1]" 2>/dev/null && eval "exec ${_cs_fd1}>&-" 2>/dev/null

		kill "$pid" 2>/dev/null || true
		wait "$pid" 2>/dev/null || true

		local i new_arr=()
		for i in "${_registry[@]}"; do
				[[ "$i" != "$_name" ]] && new_arr+=("$i")
		done
		_registry=("${new_arr[@]}")
}

# List active tracked coprocs.
# Usage: runtime::coproc::list <registry>
runtime::coproc::list() {
		local -n _registry="$1"
		local name
		for name in "${_registry[@]}"; do
				local pid; pid=$(runtime::coproc::pid "$name" 2>/dev/null)
				local alive="dead"
				runtime::coproc::alive "$name" 2>/dev/null && alive="alive"
				echo "$name pid=$pid $alive"
		done
}

# JOB CONTROL
#
# Wrappers around wait -n (Bash 4.3) and wait -p (Bash 5.1).

# Wait for the next background job, return its exit code.
# Usage: runtime::wait::next
runtime::wait::next() {
		wait -n "$@"
}

# Wait for next job, echo its PID, return its exit code.
# Requires: Bash 5.1 for -p. Falls back to wait -n on older versions.
# Usage: runtime::wait::next::pid
runtime::wait::next::pid() {
		local _pid
		if _runtime::min_bash 5.1; then
				wait -n -p _pid "$@"
		else
				wait -n "$@"
				_pid=$!
		fi
		local _ret=$?
		echo "$_pid"
		return $_ret
}

# Wait for any of the listed jobspecs, return exit code of first to finish.
# Usage: runtime::wait::any jobspec...
runtime::wait::any() {
		wait -n "$@"
}

# Wait for any of the listed jobspecs, echo PID, return exit code.
# Requires: Bash 5.1+ for -p.
# Usage: runtime::wait::any::pid jobspec...
runtime::wait::any::pid() {
		local _pid
		if _runtime::min_bash 5.1; then
				wait -n -p _pid "$@"
		else
				wait -n "$@"
				_pid=$!
		fi
		local _ret=$?
		echo "$_pid"
		return $_ret
}

# AUTO-ALLOCATED FILE DESCRIPTORS
#
# Wrappers around exec {var}<>file (Bash 4.1+). Bash picks a free fd number
# and stores it in the named variable — no risk of collision with fds 3–9.

# Open a file and get back a free fd number.
# Usage: runtime::fd::open /path/to/file [r|rw]
runtime::fd::open() {
		local _path=$1 _mode=${2:-r}
		[[ -n "$_path" ]] || { echo "runtime::fd::open: path required" >&2; return 1; }
		local _fd
		case "$_mode" in
				rw) eval "exec {_fd}<>'$_path'" || return 1 ;;
				*)  eval "exec {_fd}<'$_path'"  || return 1 ;;
		esac
		echo "$_fd"
}

# Close an auto-allocated fd (both read and write ends).
# Safe to call on already-closed fds.
# Usage: runtime::fd::close fd
runtime::fd::close() {
		eval "exec $1<&-" 2>/dev/null || true
		eval "exec $1>&-" 2>/dev/null || true
}

# Open fd, run command with FD= exported, close fd, return command's exit code.
# Usage: runtime::fd::with /path/to/log rw mycmd arg1 arg2
runtime::fd::with() {
		local _path=$1 _mode=${2:-r}; shift 2
		local _fd; _fd=$(runtime::fd::open "$_path" "$_mode") || return 1
		FD=$_fd "$@"
		local _ret=$?
		runtime::fd::close "$_fd"
		return $_ret
}

# CLOCKS
#
# High-precision clock sources and timing utilities.

# Monotonic clock — never goes backward, immune to NTP/leap seconds.
# Requires: Bash 5.3+
# Usage: t0=$(runtime::clocks::mono)
runtime::clocks::mono() {
		_runtime::min_bash 5.3 || return 1
		echo "${BASH_MONOSECONDS:-0}"
}

# Wall clock — seconds since epoch with microsecond precision.
# Requires: Bash 5.0+
# Usage: ts=$(runtime::clocks::wall)
runtime::clocks::wall() {
		_runtime::min_bash 5.0 || return 1
		echo "${EPOCHREALTIME:-0}"
}

# Elapsed seconds since a saved monotonic tick.
# Uses bc for float math (primary) or awk (fallback).
# Usage: runtime::clocks::elapsed "$t0"
runtime::clocks::elapsed() {
		local _start=${1:-}
		[[ -n "$_start" ]] || { echo "0"; return 1; }
		local _now="${BASH_MONOSECONDS:-0}"
		if runtime::has_command bc; then
				echo "$_now - $_start" | bc
		else
				awk -v now="$_now" -v start="$_start" 'BEGIN { printf "%.6f", now - start }'
		fi
}

# Time a command, print elapsed seconds, preserve exit code.
# Requires: Bash 5.3+ (for monotonic clock)
# Usage: runtime::bench sleep 1
runtime::bench() {
		local _t0; _t0=$(runtime::clocks::mono) || return 1
		"$@"
		local _ret=$?
		printf '%.6fs\n' "$(runtime::clocks::elapsed "$_t0")"
		return $_ret
}

# Time a command, store elapsed in a nameref, preserve exit code.
# Usage: runtime::bench::capture result_var sleep 1
runtime::bench::capture() {
		local -n _bench_result="$1"; shift
		local _t0; _t0=$(runtime::clocks::mono) || return 1
		"$@"
		local _ret=$?
		printf -v _bench_result '%s' "$(runtime::clocks::elapsed "$_t0")"
		return $_ret
}

# ISO-8601 timestamp with microseconds.
# Requires: Bash 5.0+ (for EPOCHREALTIME)
# Usage: runtime::timestamp
runtime::timestamp() {
		local _ts; _ts=$(runtime::clocks::wall) || return 1
		local _sec="${_ts%.*}" _us="${_ts#*.}"
		printf "%(%Y-%m-%dT%H:%M:%S)T.%s" "$_sec" "$_us"
}

# SHELL PROCESS
#
# Wrappers around shell special variables for process introspection.

# Current subshell PID — unlike $$ which is frozen to the parent shell.
# Usage: runtime::pid_current
runtime::pid_current() {
		echo "${BASHPID:-$$}"
}

# Get $0 (script name). Uses BASH_ARGV0 when available (Bash 5.0+).
# Usage: runtime::argv0::get
runtime::argv0::get() {
		echo "${BASH_ARGV0:-$0}"
}

# Set $0 to a new value.
# Requires: Bash 5.0+
# Usage: runtime::argv0::set "my-script"
runtime::argv0::set() {
		[[ -n "${1:-}" ]] || { echo "runtime::argv0::set: name required" >&2; return 1; }
		if [[ -z "${BASH_ARGV0+set}" ]]; then
				echo "runtime::argv0::set: requires Bash 5.0+" >&2; return 1
		fi
		BASH_ARGV0="$1"
}

# Get current recursion limit (FUNCNEST). 0 = unlimited.
# Usage: runtime::recurselimit::get
runtime::recurselimit::get() {
		echo "${FUNCNEST:-0}"
}

# Set recursion limit to guard against infinite recursion.
# Set to 0 to disable the limit. Bash 4.2+.
# Usage: runtime::recurselimit::set 50
runtime::recurselimit::set() {
		[[ -n "${1:-}" ]] || {
			echo "runtime::recurselimit::set: limit required" >&2
			return 1
		}
		FUNCNEST="$1"
}

# PATH CONTROL
#
# EXECIGNORE (Bash 5.0+) — colon-separated glob patterns. Executables matching
# any pattern are skipped during PATH command lookup.

# Add a pattern to EXECIGNORE.
# Usage: runtime::execignore::add '*.py'
runtime::execignore::add() {
		local _pat=$1
		[[ -n "$_pat" ]] || {
			echo "runtime::execignore::add: pattern required" >&2
			return 1
		}
		if [[ -z "${EXECIGNORE:-}" ]]; then
				EXECIGNORE="$_pat"
		else
				EXECIGNORE="$EXECIGNORE:$_pat"
		fi
}

# List current EXECIGNORE patterns, one per line.
# Usage: runtime::execignore::list
runtime::execignore::list() {
		if [[ -n "${EXECIGNORE:-}" ]]; then
				echo "${EXECIGNORE}" | tr ':' '\n'
		fi
}

# Clear all EXECIGNORE patterns.
# Usage: runtime::execignore::clear
runtime::execignore::clear() {
		EXECIGNORE=""
}


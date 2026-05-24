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

    local _s="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-${GDMSESSION:-}}}"
    case "${_s,,}" in
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
        [gnome-shell]=gnome   [plasmashell]=kde      [xfce4-session]=xfce
        [lxqt-session]=lxqt   [lxsession]=lxde       [mate-session]=mate
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

    local _s="${XDG_SESSION_DESKTOP:-}"
    case "${_s,,}" in
        *hyprland*) echo "hyprland"; return ;;
        *sway*)     echo "sway";     return ;;
        *wayfire*)  echo "wayfire";  return ;;
        *river*)    echo "river";    return ;;
    esac

    if runtime::has_command xprop && [[ -n "${DISPLAY:-}" ]]; then
        local _n
        _n=$(xprop -root -notype _NET_WM_NAME 2>/dev/null | sed 's/.*= *"//;s/".*//')
        [[ -n "$_n" ]] && echo "${_n,,}" && return
    fi

    local -A _procs=(
        [hyprland]=hyprland      [sway]=sway          [wayfire]=wayfire
        [river]=river            [mutter]=mutter       [kwin_wayland]=kwin
        [kwin_x11]=kwin          [xfwm4]=xfwm4        [openbox]=openbox
        [i3]=i3                  [bspwm]=bspwm         [awesome]=awesome
        [herbstluftwm]=herbstluftwm                   [fluxbox]=fluxbox
        [icewm]=icewm            [jwm]=jwm             [qtile]=qtile
        [xmonad]=xmonad          [marco]=marco         [metacity]=metacity
        [compiz]=compiz          [enlightenment]=enlightenment
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
  ps -p 1 -o comm=
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
  [[ $(runtime::os) == "linux" ]] || return 1
  # Number only, case of checks where you don't care about types
  local v
  v=$(uname -r)
  printf '%s\n' "${v%%-*}"
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
      echo "runtime::request_root: sudo requires a password but no terminal is available, will attempt alternatives." >&2
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
  Linux*) echo "linux" ;;
  Darwin*) echo "darwin" ;;
  CYGWIN*) echo "cygwin" ;;
  MINGW*) echo "mingw" ;;
  *) echo "unknown" ;;
  esac
}

runtime::arch() {
  case "$(uname -m)" in
  x86_64) echo "amd64" ;;
  i386) echo "386" ;;
  armv7l) echo "armv7" ;;
  aarch64) echo "arm64" ;;
  *) echo "unknown" ;;
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
  if runtime::has_command apt-get; then
    echo "apt"
  elif runtime::has_command pacman; then
    echo "pacman"
  elif runtime::has_command dnf; then
    echo "dnf"
  elif runtime::has_command yum; then
    echo "yum"
  elif runtime::has_command zypper; then
    echo "zypper"
  elif runtime::has_command apk; then
    echo "apk"
  elif runtime::has_command brew; then
    echo "brew"
  elif runtime::has_command pkg; then
    echo "pkg"
  elif runtime::has_command xbps-install; then
    echo "xbps"
  elif runtime::has_command nix-env; then
    echo "nix"
  else
    echo "unknown"
  fi
}

# ==============================================================================
# COPROC
# ==============================================================================

# Active coproc tracking array.
declare -a _RUNTIME_COPROCS=()

# Start a named coprocess. Stores name for tracking.
# Usage: runtime::coproc::start <name> <command...>
runtime::coproc::start() {
    local name=$1; shift
    if [[ -z "$name" ]]; then
        echo "runtime::coproc::start: name required" >&2
        return 1
    fi
    if [[ " ${_RUNTIME_COPROCS[*]} " == *" $name "* ]]; then
        echo "runtime::coproc::start: coproc '$name' already exists" >&2
        return 1
    fi
    coproc "$name" { "$@" 2>&1; }
    _RUNTIME_COPROCS+=("$name")
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
# Usage: runtime::coproc::stop <name>
runtime::coproc::stop() {
    local name=$1
    local pid; pid=$(runtime::coproc::pid "$name" 2>/dev/null) || return 1

    local -n _cs_fd="${name}[0]" 2>/dev/null && eval "exec ${_cs_fd}<&-" 2>/dev/null
    local -n _cs_fd1="${name}[1]" 2>/dev/null && eval "exec ${_cs_fd1}>&-" 2>/dev/null

    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true

    local i new_arr=()
    for i in "${_RUNTIME_COPROCS[@]}"; do
        [[ "$i" != "$name" ]] && new_arr+=("$i")
    done
    _RUNTIME_COPROCS=("${new_arr[@]}")
}

# List active tracked coprocs.
# Usage: runtime::coproc::list
runtime::coproc::list() {
    local name
    for name in "${_RUNTIME_COPROCS[@]}"; do
        local pid; pid=$(runtime::coproc::pid "$name" 2>/dev/null)
        local alive="dead"
        runtime::coproc::alive "$name" 2>/dev/null && alive="alive"
        echo "$name pid=$pid $alive"
    done
}

# ==============================================================================
# PROCESS
# ==============================================================================

# Cache for /proc/<pid>/stat parsing: _RUNTIME_PROC_CACHE[<pid>:<field>]
declare -A _RUNTIME_PROC_CACHE

# Internal: parse /proc/<pid>/stat and cache all fields.
_runtime::parse_stat() {
    local pid=$1
    local cache_key="${pid}:parsed"
    [[ -n "${_RUNTIME_PROC_CACHE[$cache_key]:-}" ]] && return 0

    [[ "$(runtime::os)" != "linux" ]] && return 1

    local stat_file="/proc/$pid/stat"
    [[ -f "$stat_file" ]] || return 1

    local raw; raw=$(cat "$stat_file" 2>/dev/null)
    [[ -z "$raw" ]] && return 1

    # Split: "1234 (comm) S 5678 ..." → extract comm between parens
    local comm_start comm_end rest
    comm_start="${raw#*(}"
    comm_end="${comm_start%)*}"
    rest="${comm_start#*) }"

    local -a fields
    read -ra fields <<< "$rest"

    _RUNTIME_PROC_CACHE["$pid:pid"]="$pid"
    _RUNTIME_PROC_CACHE["$pid:comm"]="$comm_end"
    _RUNTIME_PROC_CACHE["$pid:state"]="${fields[0]}"
    _RUNTIME_PROC_CACHE["$pid:ppid"]="${fields[1]}"
    _RUNTIME_PROC_CACHE["$pid:threads"]="${fields[17]}"
    _RUNTIME_PROC_CACHE["$pid:rss"]="$(( ${fields[21]} * 4 ))"
    _RUNTIME_PROC_CACHE["$pid:vsize"]="${fields[20]}"
    _RUNTIME_PROC_CACHE["$pid:utime"]="${fields[12]}"
    _RUNTIME_PROC_CACHE["$pid:stime"]="${fields[13]}"
    _RUNTIME_PROC_CACHE["$pid:starttime"]="${fields[19]}"

    local clk_tck=100 uptime boot_ticks
    uptime=$(awk '{printf "%.0f", $1}' /proc/uptime 2>/dev/null)
    boot_ticks=$(( ${_RUNTIME_PROC_CACHE["$pid:starttime"]} / clk_tck ))
    _RUNTIME_PROC_CACHE["$pid:uptime"]=$(( uptime - boot_ticks ))

    _RUNTIME_PROC_CACHE[$cache_key]=1
}

# Check if a PID exists.
# Usage: runtime::process::exists <pid>
runtime::process::exists() {
    kill -0 "$1" 2>/dev/null
}

# Echo the parent PID.
# Usage: runtime::process::ppid <pid>
runtime::process::ppid() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:ppid]}"
}

# Echo the process state: R/S/D/Z/T.
# Usage: runtime::process::state <pid>
runtime::process::state() {
    _runtime::parse_stat "$1" || return 1
    echo "${_RUNTIME_PROC_CACHE[$1:state]}"
}

# Echo resident memory in KB.
# Usage: runtime::process::rss <pid>
runtime::process::rss() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:rss]}"
}

# Echo virtual memory in KB.
# Usage: runtime::process::vsize <pid>
runtime::process::vsize() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:vsize]}"
}

# Echo the full command line (null-separated args joined with spaces).
# Usage: runtime::process::cmdline <pid>
runtime::process::cmdline() {
    [[ "$(runtime::os)" == "linux" && -f "/proc/$1/cmdline" ]] || return 1
    tr '\0' ' ' < "/proc/$1/cmdline"
}

# Echo the short command name (comm).
# Usage: runtime::process::comm <pid>
runtime::process::comm() {
    _runtime::parse_stat "$1" || return 1
    echo "${_RUNTIME_PROC_CACHE[$1:comm]}"
}

# Echo the thread count.
# Usage: runtime::process::threads <pid>
runtime::process::threads() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:threads]}"
}

# Echo seconds since process start.
# Usage: runtime::process::uptime <pid>
runtime::process::uptime() {
    _runtime::parse_stat "$1" || { echo "0"; return 1; }
    echo "${_RUNTIME_PROC_CACHE[$1:uptime]}"
}

# List child PIDs (space-separated).
# Usage: runtime::process::children <pid>
runtime::process::children() {
    [[ "$(runtime::os)" == "linux" ]] || return 1
    local children; children=$(pgrep -P "$1" 2>/dev/null | tr '\n' ' ')
    echo "${children% }"
}

# Parse full /proc/<pid>/stat and output all fields or a specific one.
# Usage: runtime::process::info <pid> [field]
runtime::process::info() {
    local pid=$1 field=$2
    _runtime::parse_stat "$pid" || return 1

    if [[ -n "$field" ]]; then
        echo "${_RUNTIME_PROC_CACHE[$pid:$field]:-}"
        return
    fi

    for field in pid comm state ppid threads rss vsize utime stime uptime; do
        printf '%s=%s\n' "$field" "${_RUNTIME_PROC_CACHE[$pid:$field]:-}"
    done
}

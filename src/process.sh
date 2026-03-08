#!/usr/bin/env bash
# process.sh — bash-frameheader process management lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# QUERY
# ==============================================================================

# Check if a process is running by PID
# Usage: process::is_running pid
process::is_running() {
    kill -0 "$1" 2>/dev/null
}

# Check if a process is running by name
# Usage: process::is_running::name name
process::is_running::name() {
    pgrep -x "$1" >/dev/null 2>&1
}

# Get PID(s) of a named process (one per line)
# Usage: process::pid name
process::pid() {
    pgrep -x "$1" 2>/dev/null
}

# Get parent PID of a process
# Usage: process::ppid pid
process::ppid() {
    local pid="${1:-$$}"
    awk '{print $4}' "/proc/$pid/stat" 2>/dev/null || \
        ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' '
}

# Get PID of current shell
process::self() {
    echo "$$"
}

# Get process name from PID
# Usage: process::name pid
process::name() {
    if [[ -f "/proc/${1}/comm" ]]; then
        cat "/proc/${1}/comm"
    else
        ps -o comm= -p "$1" 2>/dev/null
    fi
}

# Get command line of a process
# Usage: process::cmdline pid
process::cmdline() {
    if [[ -f "/proc/${1}/cmdline" ]]; then
        tr '\0' ' ' < "/proc/${1}/cmdline"
    else
        ps -o args= -p "$1" 2>/dev/null
    fi
}

# Get process state (R=running, S=sleeping, Z=zombie, etc.)
# Usage: process::state pid
process::state() {
    if [[ -f "/proc/${1}/status" ]]; then
        awk '/^State:/{print $2}' "/proc/${1}/status"
    else
        ps -o state= -p "$1" 2>/dev/null
    fi
}

# Check if a process is a zombie
process::is_zombie() {
    [[ "$(process::state "$1")" == "Z" ]]
}

# Get process working directory
# Usage: process::cwd pid
process::cwd() {
    readlink "/proc/${1}/cwd" 2>/dev/null || \
        lsof -p "$1" 2>/dev/null | awk '$4=="cwd"{print $9}'
}

# Get process environment variable
# Usage: process::env pid varname
process::env() {
    if [[ -f "/proc/${1}/environ" ]]; then
        tr '\0' '\n' < "/proc/${1}/environ" | grep "^${2}=" | cut -d= -f2-
    fi
}

# List all running processes (PID and name)
process::list() {
    ps -eo pid,comm --no-headers 2>/dev/null || \
        ps -eo pid,comm 2>/dev/null | tail -n +2
}

# Find processes matching a pattern (name or cmdline)
# Usage: process::find pattern
process::find() {
    pgrep -a "$1" 2>/dev/null || ps -eo pid,args | grep "$1" | grep -v grep
}

# Get process tree from a PID
# Usage: process::tree [pid]
process::tree() {
    local pid="${1:-1}"
    if runtime::has_command pstree; then
        pstree -p "$pid"
    else
        ps -eo pid,ppid,comm | awk -v root="$pid" '
            NR==1{next}
            {parent[$1]=$2; name[$1]=$3}
            function show(p, indent,    c) {
                print indent p " " name[p]
                for (c in parent)
                    if (parent[c]==p) show(c, indent "  ")
            }
            END{show(root, "")}
        '
    fi
}

# ==============================================================================
# RESOURCE USAGE
# ==============================================================================

# Get CPU usage percentage for a PID
# Usage: process::cpu pid
process::cpu() {
    ps -o pcpu= -p "$1" 2>/dev/null | tr -d ' '
}

# Get memory usage in KB for a PID
# Usage: process::memory pid
process::memory() {
    if [[ -f "/proc/${1}/status" ]]; then
        awk '/^VmRSS:/{print $2}' "/proc/${1}/status"
    else
        ps -o rss= -p "$1" 2>/dev/null | tr -d ' '
    fi
}

# Get memory usage as percentage
process::memory::percent() {
    ps -o pmem= -p "$1" 2>/dev/null | tr -d ' '
}

# Get number of open file descriptors for a PID
process::fd_count() {
    ls "/proc/${1}/fd" 2>/dev/null | wc -l
}

# Get number of threads for a PID
process::thread_count() {
    if [[ -f "/proc/${1}/status" ]]; then
        awk '/^Threads:/{print $2}' "/proc/${1}/status"
    else
        ps -o nlwp= -p "$1" 2>/dev/null | tr -d ' '
    fi
}

# Get process start time (unix timestamp)
process::start_time() {
    ps -o lstart= -p "$1" 2>/dev/null
}

# Get process uptime in seconds
process::uptime() {
    if [[ -f "/proc/${1}/stat" ]]; then
        local clk_tck start_ticks uptime_secs
        clk_tck=$(getconf CLK_TCK 2>/dev/null || echo 100)
        start_ticks=$(awk '{print $22}' "/proc/${1}/stat")
        uptime_secs=$(awk '{print $1}' /proc/uptime)
        echo "$(( ${uptime_secs%.*} - start_ticks / clk_tck ))"
    fi
}

# ==============================================================================
# CONTROL
# ==============================================================================

# Send a signal to a process
# Usage: process::signal pid signal
process::signal() {
    kill -"$2" "$1" 2>/dev/null
}

# Terminate a process (SIGTERM)
process::kill() {
    kill -TERM "$1" 2>/dev/null
}

# Force kill a process (SIGKILL)
process::kill::force() {
    kill -KILL "$1" 2>/dev/null
}

# Kill all processes matching a name
process::kill::name() {
    pkill -x "$1" 2>/dev/null
}

# Graceful kill — SIGTERM, wait, then SIGKILL if still running
# Usage: process::kill::graceful pid [timeout_seconds]
process::kill::graceful() {
    process::is_running "$1" || return 0

    # SIGCONT first — a stopped process ignores SIGTERM
    kill -CONT "$1" 2>/dev/null
    kill -TERM "$1" 2>/dev/null

    local elapsed=0
    while (( elapsed < ${2:-5} )); do
        process::is_running "$1" || return 0
        sleep 1
        (( elapsed++ ))
    done

    # Still running after timeout — force kill
    kill -KILL "$1" 2>/dev/null
    local i
    for (( i = 0; i < 5; i++ )); do
        process::is_running "$1" || return 0
        sleep 0.2
    done
    return 1
}

# Suspend a process (SIGSTOP)
process::suspend() {
    kill -STOP "$1" 2>/dev/null
}

# Resume a suspended process (SIGCONT)
process::resume() {
    kill -CONT "$1" 2>/dev/null
}

# Reload a process config (SIGHUP)
process::reload() {
    kill -HUP "$1" 2>/dev/null
}

# Wait for a process to finish
# Usage: process::wait pid [timeout_seconds]
process::wait() {
    if [[ -z "${2:-}" ]]; then
        wait "$1" 2>/dev/null
        return $?
    fi

    local elapsed=0
    while process::is_running "$1"; do
        sleep 1
        (( elapsed++ ))
        (( elapsed >= ${2:-} )) && return 1
    done
    return 0
}

# Change process priority (nice value, -20 to 19)
# Usage: process::renice pid value
process::renice() {
    renice -n "$2" -p "$1" 2>/dev/null
}

# ==============================================================================
# BACKGROUND JOBS
# ==============================================================================

# Run a command in the background, print its PID
# Usage: process::run_bg command [args...]
process::run_bg() {
    "$@" &
    echo $!
}

# Run a command in the background, redirect output to a log file
# Usage: process::run_bg::log logfile command [args...]
process::run_bg::log() {
    "$@" >> "$1" 2>&1 &
    echo $!
}

# Run a command in the background with a timeout
# Usage: process::run_bg::timeout seconds command [args...]
process::run_bg::timeout() {
    (
        "$2" &
        local pid=$!
        sleep "$1"
        process::kill::graceful "$pid"
    ) &
    echo $!
}

# List current shell's background jobs
process::job::list() {
    jobs -l
}

# Wait for all background jobs to finish
process::job::wait_all() {
    wait
}

# Wait for a specific background job by PID
process::job::wait() {
    wait "$1" 2>/dev/null
    return $?
}

# Get exit status of last background job
process::job::status() {
    wait "$1" 2>/dev/null
    echo $?
}

# ==============================================================================
# LOCKING
# Prevent concurrent execution of a script/function
# ==============================================================================

# Acquire a lock — returns 1 if already locked
# Usage: process::lock::acquire lockname
process::lock::acquire() {
    local lockfile="/tmp/fsbshf_${1}.lock"
    if ( set -o noclobber; echo "$$" > "$lockfile" ) 2>/dev/null; then
        trap "process::lock::release '${1}'" EXIT
        return 0
    fi
    # Check if the locking process is still alive
    local locked_pid
    locked_pid=$(cat "$lockfile" 2>/dev/null)
    if [[ -n "$locked_pid" ]] && ! process::is_running "$locked_pid"; then
        rm -f "$lockfile"
        ( set -o noclobber; echo "$$" > "$lockfile" ) 2>/dev/null
        trap "process::lock::release '${1}'" EXIT
        return 0
    fi
    return 1
}

# Release a lock
# Usage: process::lock::release lockname
process::lock::release() {
    rm -f "/tmp/fsbshf_${1}.lock"
}

# Check if a lock is held
# Usage: process::lock::is_locked lockname
process::lock::is_locked() {
    local lockfile="/tmp/fsbshf_${1}.lock"
    [[ -f "$lockfile" ]] && process::is_running "$(cat "$lockfile" 2>/dev/null)"
}

# Wait for a lock to become available
# Usage: process::lock::wait lockname [timeout]
process::lock::wait() {
    local elapsed=0
    while ! process::lock::acquire "$1"; do
        sleep 1
        (( elapsed++ ))
        (( elapsed >= ${2:-30} )) && return 1
    done
    return 0
}

# ==============================================================================
# DAEMON / SERVICE
# ==============================================================================

# Check if a systemd service is running
# Usage: process::service::is_running service_name
process::service::is_running() {
    if runtime::has_command systemctl; then
        systemctl is-active --quiet "$1" 2>/dev/null
    elif runtime::has_command service; then
        service "$1" status >/dev/null 2>&1
    else
        process::is_running::name "$1"
    fi
}

# Start a systemd service
process::service::start() {
    if runtime::has_command systemctl; then
        systemctl start "$1"
    elif runtime::has_command service; then
        service "$1" start
    fi
}

# Stop a systemd service
process::service::stop() {
    if runtime::has_command systemctl; then
        systemctl stop "$1"
    elif runtime::has_command service; then
        service "$1" stop
    fi
}

# Restart a systemd service
process::service::restart() {
    if runtime::has_command systemctl; then
        systemctl restart "$1"
    elif runtime::has_command service; then
        service "$1" restart
    fi
}

# Check if a service is enabled at boot
process::service::is_enabled() {
    if runtime::has_command systemctl; then
        systemctl is-enabled --quiet "$1" 2>/dev/null
    fi
}

# ==============================================================================
# MISC
# ==============================================================================

# Run a command and return its execution time in seconds
# Usage: process::time command [args...]
process::time() {
    local start end
    start=$(date +%s%N 2>/dev/null || date +%s)
    "$@"
    local ret=$?
    end=$(date +%s%N 2>/dev/null || date +%s)
    # nanosecond precision if available
    if [[ "${#start}" -gt 10 ]]; then
        echo "$(( (end - start) / 1000000 ))ms"
    else
        echo "$(( end - start ))s"
    fi
    return $ret
}

# Run a command with a timeout, kill it if it exceeds
# Usage: process::timeout seconds command [args...]
process::timeout() {
    if runtime::has_command timeout; then
        timeout "$1" "${@:2}"
    else
        # Pure bash fallback
        "${@:2}" &
        local pid=$!
        ( sleep "$1"; process::kill::graceful "$pid" ) &
        local watcher=$!
        wait "$pid" 2>/dev/null
        local ret=$?
        kill "$watcher" 2>/dev/null
        return $ret
    fi
}

# Retry a command n times with a delay between attempts
# Usage: process::retry times delay command [args...]
process::retry() {
    local attempt=0
    while (( attempt < $1 )); do
        "${@:3}" && return 0
        (( attempt++ ))
        (( attempt < $1 )) && sleep "$2"
    done
    return 1
}

# Run command only if not already running (singleton)
# Usage: process::singleton lockname command [args...]
process::singleton() {
    if process::lock::acquire "$1"; then
        "${@:2}"
    else
        echo "process::singleton: '$1' is already running" >&2
        return 1
    fi
}

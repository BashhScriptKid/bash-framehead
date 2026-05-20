# `process`

Process management — querying, resource monitoring, signal control, background jobs, locking, service management, and command execution helpers. **51 functions.** No `::fast` variants.

---

## Query

| Function | Description |
|----------|-------------|
| `process::is_running` | Check if a process is running by PID |
| `process::is_running::name` | Check if a process is running by name |
| `process::pid` | Get PID(s) of a named process (one per line) |
| `process::ppid` | Get parent PID of a process |
| `process::self` | Get PID of current shell |
| `process::name` | Get process name from PID |
| `process::cmdline` | Get full command line of a process |
| `process::state` | Get process state (R=running, S=sleeping, Z=zombie, etc.) |
| `process::is_zombie` | Check if a process is a zombie |
| `process::cwd` | Get process working directory |
| `process::env` | Get a specific environment variable from a process |
| `process::list` | List all running processes (PID and name) |
| `process::find` | Find processes matching a pattern (name or cmdline) |
| `process::tree` | Get process tree from a PID |

```bash
process::is_running 1234 && echo "Still running"
process::pid "nginx"           # Lists all nginx PIDs
process::name 1234             # → "nginx"
process::state 1234            # → "S" (sleeping)
process::cwd 1234              # → "/var/www"
process::find "python"         # Find all python processes
process::tree $$               # Print current shell's process tree
```

## Resource Usage

| Function | Description |
|----------|-------------|
| `process::cpu` | Get CPU usage percentage for a PID |
| `process::memory` | Get memory usage in KB for a PID |
| `process::memory::percent` | Get memory usage as percentage of total |
| `process::fd_count` | Get number of open file descriptors for a PID |
| `process::thread_count` | Get number of threads for a PID |
| `process::start_time` | Get process start time (unix timestamp) |
| `process::uptime` | Get process uptime in seconds |

```bash
process::cpu 1234              # → 2.5
process::memory 1234           # → 51200 (KB)
process::memory::percent 1234  # → 0.3
process::uptime 1234           # → 3600 (seconds)
```

## Process Control

| Function | Description |
|----------|-------------|
| `process::signal` | Send an arbitrary signal to a process |
| `process::kill` | Terminate a process (SIGTERM) |
| `process::kill::force` | Force kill a process (SIGKILL) |
| `process::kill::name` | Kill all processes matching a name |
| `process::kill::graceful` | Graceful kill — SIGTERM, wait, then SIGKILL if still running |
| `process::suspend` | Suspend a process (SIGSTOP) |
| `process::resume` | Resume a suspended process (SIGCONT) |
| `process::reload` | Reload process config (SIGHUP) |
| `process::wait` | Wait for a process to finish |
| `process::renice` | Change process priority (nice value, -20 to 19) |

```bash
process::signal 1234 SIGUSR1
process::kill 1234
process::kill::graceful 1234 10  # 10 second timeout
process::kill::name "stale-worker"
process::wait 1234 30            # wait up to 30 seconds
```

## Background Jobs

| Function | Description |
|----------|-------------|
| `process::run_bg` | Run a command in the background, print its PID |
| `process::run_bg::log` | Run in background, redirect output to a log file |
| `process::run_bg::timeout` | Run in background with a timeout |
| `process::job::list` | List current shell's background jobs |
| `process::job::wait_all` | Wait for all background jobs to finish |
| `process::job::wait` | Wait for a specific background job by PID |
| `process::job::status` | Get exit status of last background job |

```bash
pid=$(process::run_bg "sleep 30")
process::run_bg::log "/tmp/task.log" "long_running_task" "--verbose"
process::job::wait "$pid"
echo "Job exited with: $(process::job::status)"
```

## Locking

File-based advisory locks for mutual exclusion.

| Function | Description |
|----------|-------------|
| `process::lock::acquire` | Acquire a named lock — returns 1 if already locked |
| `process::lock::release` | Release a named lock |
| `process::lock::is_locked` | Check if a lock is held |
| `process::lock::wait` | Wait for a lock to become available (with optional timeout) |

```bash
if process::lock::acquire "backup-job"; then
    trap 'process::lock::release "backup-job"' EXIT
    perform_backup
else
    echo "Backup already running"
fi
```

## Systemd Services

| Function | Description |
|----------|-------------|
| `process::service::is_running` | Check if a systemd service is running |
| `process::service::start` | Start a systemd service |
| `process::service::stop` | Stop a systemd service |
| `process::service::restart` | Restart a systemd service |
| `process::service::is_enabled` | Check if a service is enabled at boot |

```bash
if ! process::service::is_running "nginx"; then
    process::service::start "nginx"
fi
```

## Command Helpers

| Function | Description |
|----------|-------------|
| `process::time` | Run a command and return its execution time in seconds |
| `process::timeout` | Run a command with a timeout, kill if exceeded |
| `process::retry` | Retry a command n times with a delay between attempts |
| `process::singleton` | Run a command only if not already running (singleton pattern) |

```bash
elapsed=$(process::time "curl -s https://example.com")
process::timeout 10 "slow_command" "--flag"
process::retry 5 2 "flaky_api_call"     # 5 retries, 2s delay
process::singleton "daily-cleanup" "cleanup_script.sh"
```

## Dependencies

- **Requires**: `runtime`
- **External tools**: `ps`, `kill`, `nice`/`renice`, `systemctl` (for service functions)

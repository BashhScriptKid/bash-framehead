# `process`

51 functions. [Guide](../guide/index.md) — [Dictionary](index.md)

| Function | Signature | Description |
|----------|-----------|-------------|
| [`process::cmdline`](process/cmdline.md) | `process::cmdline(pid)` |  |
| [`process::cpu`](process/cpu.md) | `process::cpu(pid)` |  |
| [`process::cwd`](process/cwd.md) | `process::cwd(pid)` |  |
| [`process::env`](process/env.md) | `process::env(pid, varname)` |  |
| [`process::fd_count`](process/fd_count.md) | `process::fd_count(arg1)` |  |
| [`process::find`](process/find.md) | `process::find(pattern)` |  |
| [`process::is_running`](process/is_running.md) | `process::is_running(pid)` |  |
| [`process::is_running::name`](process/is_running/name.md) | `process::is_running::name(name)` |  |
| [`process::is_zombie`](process/is_zombie.md) | `process::is_zombie(arg1)` |  |
| [`process::job::list`](process/job/list.md) | `process::job::list()` |  |
| [`process::job::status`](process/job/status.md) | `process::job::status(arg1)` |  |
| [`process::job::wait_all`](process/job/wait_all.md) | `process::job::wait_all()` |  |
| [`process::job::wait`](process/job/wait.md) | `process::job::wait(arg1)` |  |
| [`process::kill::force`](process/kill/force.md) | `process::kill::force(arg1)` |  |
| [`process::kill::graceful`](process/kill/graceful.md) | `process::kill::graceful(pid, [timeout_seconds])` |  |
| [`process::kill`](process/kill.md) | `process::kill(arg1)` |  |
| [`process::kill::name`](process/kill/name.md) | `process::kill::name(arg1)` |  |
| [`process::list`](process/list.md) | `process::list()` |  |
| [`process::lock::acquire`](process/lock/acquire.md) | `process::lock::acquire(lockname)` |  |
| [`process::lock::is_locked`](process/lock/is_locked.md) | `process::lock::is_locked(lockname)` |  |
| [`process::lock::release`](process/lock/release.md) | `process::lock::release(lockname)` |  |
| [`process::lock::wait`](process/lock/wait.md) | `process::lock::wait(lockname, [timeout])` |  |
| [`process::memory`](process/memory.md) | `process::memory(pid)` |  |
| [`process::memory::percent`](process/memory/percent.md) | `process::memory::percent(arg1)` |  |
| [`process::name`](process/name.md) | `process::name(pid)` |  |
| [`process::pid`](process/pid.md) | `process::pid(name)` |  |
| [`process::ppid`](process/ppid.md) | `process::ppid(pid)` |  |
| [`process::reload`](process/reload.md) | `process::reload(arg1)` |  |
| [`process::renice`](process/renice.md) | `process::renice(pid, value)` |  |
| [`process::resume`](process/resume.md) | `process::resume(arg1)` |  |
| [`process::retry`](process/retry.md) | `process::retry(times, delay, command, [args...])` |  |
| [`process::run_bg::log`](process/run_bg/log.md) | `process::run_bg::log(logfile, command, [args...])` |  |
| [`process::run_bg`](process/run_bg.md) | `process::run_bg(command, [args...])` |  |
| [`process::run_bg::timeout`](process/run_bg/timeout.md) | `process::run_bg::timeout(seconds, command, [args...])` |  |
| [`process::self`](process/self.md) | `process::self()` |  |
| [`process::service::is_enabled`](process/service/is_enabled.md) | `process::service::is_enabled(arg1)` |  |
| [`process::service::is_running`](process/service/is_running.md) | `process::service::is_running(service_name)` |  |
| [`process::service::restart`](process/service/restart.md) | `process::service::restart(arg1)` |  |
| [`process::service::start`](process/service/start.md) | `process::service::start(arg1)` |  |
| [`process::service::stop`](process/service/stop.md) | `process::service::stop(arg1)` |  |
| [`process::signal`](process/signal.md) | `process::signal(pid, signal)` |  |
| [`process::singleton`](process/singleton.md) | `process::singleton(lockname, command, [args...])` |  |
| [`process::start_time`](process/start_time.md) | `process::start_time(arg1)` |  |
| [`process::state`](process/state.md) | `process::state(pid)` |  |
| [`process::suspend`](process/suspend.md) | `process::suspend(arg1)` |  |
| [`process::thread_count`](process/thread_count.md) | `process::thread_count(arg1, arg2)` |  |
| [`process::time`](process/time.md) | `process::time(command, [args...])` |  |
| [`process::timeout`](process/timeout.md) | `process::timeout(seconds, command, [args...])` |  |
| [`process::tree`](process/tree.md) | `process::tree([pid])` |  |
| [`process::uptime`](process/uptime.md) | `process::uptime(arg1, arg2)` |  |
| [`process::wait`](process/wait.md) | `process::wait(pid, [timeout_seconds])` |  |


# ext/systemd — bash-framehead systemd client

Wraps the `systemd` suite of CLI tools (`systemctl`, `journalctl`,
`loginctl`, `timedatectl`, `hostnamectl`, `machinectl`, `systemd-run`,
`systemd-analyze`, plus adjacent tools) into a uniform namespaced Bash API.

## Dependencies

- **bash-framehead core**: `runtime`
- **External**: `systemctl` (required); other systemd tools optional and
  checked at call time via `runtime::has_command` (matches the convention
  in `src/process.sh` etc.)

## Cross-platform notice

**Linux + systemd only.** This extension will not load on macOS, BSDs, or
non-systemd Linux inits (runit, s6, dinit, openrc). The guard refuses to
load if `systemctl` is missing. Adjacent-tool stubs (see below) refuse to
execute if their specific binary is missing, even when the extension
itself loaded successfully.

## Quickstart

```bash
source ./bash-framehead.sh
source ./ext/systemd/systemd.sh

systemd::version                      # 260
systemd::hostname::get                # hostname
systemd::services::isactive sshd      # 0 if active, 1 if not
systemd::unit::pid sshd               # main PID, empty if not running
systemd::timedate::timezone           # "Europe/Berlin"
systemd::journal::boots               # list of boot entries
```

## Configuration

| Variable | Default | Effect |
|---|---|---|
| `_SYSTEMD_DEFAULT_SCOPE` | `system` | One of `system` / `user`. Affects the `--user` flag on unit / journal / run calls. Toggled via `systemd::scope::set`. |
| `_SYSTEMD_OUTPUT` | `short` | One of `short` / `json` / `pretty`. Output format hint for read calls that support it. |

---

## Subsystems

### Cross-cutting

| Function | Purpose |
|---|---|
| `systemd::version` | Echo the major systemd version detected at source time. |
| `systemd::machineid` | `/etc/machine-id`. |
| `systemd::bootid` | Current boot id. |
| `systemd::userid` | Current user's uid. |
| `systemd::info` | Single JSON blob from `hostnamectl --json=short`. |

### Scope

| Function | Purpose |
|---|---|
| `systemd::scope::get` | Echo "system" or "user". |
| `systemd::scope::set <s\|u\|system\|user>` | Set the default scope. |
| `systemd::scope::isuser` | Return 0 if scope is user. |
| `systemd::scope::issystem` | Return 0 if scope is system. |

The scope flag (`--user` or empty) is auto-applied to all unit / journal /
run calls based on the current scope.

### Unit (generic; works with any unit type)

Read:

| Function | Purpose |
|---|---|
| `systemd::unit::list [pattern...]` | Active units. |
| `systemd::unit::listloaded [pattern...]` | All loaded (incl. inactive). |
| `systemd::unit::listfiles [pattern...]` | Unit file state. |
| `systemd::unit::exists <name>` | Return 0 if unit exists. |
| `systemd::unit::isactive <name>` | Return 0 if active. |
| `systemd::unit::isfailed <name>` | Return 0 if failed. |
| `systemd::unit::isenabled <name>` | Return 0 if enabled. |
| `systemd::unit::ismasked <name>` | Return 0 if masked. |
| `systemd::unit::pid <name>` | Main PID (empty if not running). |
| `systemd::unit::show <name> <field>` | Single property value. |
| `systemd::unit::field <name> <field>` | Synonym for `show`. |
| `systemd::unit::status <name>` | Human-readable status block. |
| `systemd::unit::statusjson <name>` | Structured status as JSON. |
| `systemd::unit::cat <name>` | Unit file + drop-ins. |

Templates / instances:

| Function | Purpose |
|---|---|
| `systemd::unit::istemplate <name>` | 0 if `*@.suffix` pattern. |
| `systemd::unit::isinstance <name>` | 0 if `foo@bar.suffix` pattern. |
| `systemd::unit::template <instance>` | `foo@bar.service` → `foo@.service`. |
| `systemd::unit::instance <tmpl> <name>` | `foo@.service` + `bar` → `foo@bar.service`. |
| `systemd::unit::instances <template>` | List all instances of a template. |

Write:

| Function | Purpose |
|---|---|
| `systemd::unit::start / stop / restart <name...>` | Lifecycle. |
| `systemd::unit::tryrestart <name...>` | Restart only if active. |
| `systemd::unit::reload <name...>` | Reload config. |
| `systemd::unit::reloadorrestart <name...>` | Reload, fall back to restart. |
| `systemd::unit::enable / disable <name...>` | Boot enablement. |
| `systemd::unit::enablenow / disablenow <name...>` | Enable/disable + start/stop. |
| `systemd::unit::mask / unmask <name...>` | Link to /dev/null. |
| `systemd::unit::kill <name> [signal]` | Send signal to cgroup. |
| `systemd::unit::revert <name...>` | Drop overrides, revert to vendor. |
| `systemd::unit::daemonreload` | Reload systemd manager config. |

All write operations pass `--no-ask-password` to prevent hangs.

### Services (.service typed sugar)

Pure pass-through to `systemd::unit::*`. No auto-suffix logic — `systemctl`
already appends `.service` when missing. Functions exposed:

```
start  stop  restart  tryrestart  reload  reloadorrestart
enable  disable  enablenow  disablenow
mask  unmask  kill
exists  isactive  isfailed  isenabled  ismasked
status  statusjson  field
```

Use this namespace when you're explicitly working with `.service` units
and want a discoverable "all the service things" group. The implementation
is one-line delegation; the value is grep-ability.

### Journal

`read` and `follow` are the workhorses. The rest are single-filter
convenience wrappers. `until` is renamed to `untilnow` because `until` is
a Bash reserved word.

| Function | Wraps |
|---|---|
| `read [flags...]` | `journalctl` (one-shot). |
| `follow [flags...]` | `journalctl -f` (blocks). |
| `unit <name> [flags...]` | `journalctl -u <name>`. |
| `since <time> [flags...]` | `journalctl --since`. |
| `untilnow <time> [flags...]` | `journalctl --until`. |
| `priority <0-7> [flags...]` | `journalctl -p`. |
| `grep <pattern> [flags...]` | `journalctl --grep`. |
| `boot <offset> [flags...]` | `journalctl -b`. |
| `cursor <cursor> [flags...]` | `journalctl --cursor`. |
| `boots` | `journalctl --list-boots`. |
| `diskusage` | `journalctl --disk-usage`. |
| `verify` | `journalctl --verify`. |

`read` / `follow` / the filter helpers all pass `--no-pager` by default.

### Analyze

| Function | Purpose |
|---|---|
| `systemd::analyze::blame [pattern...]` | Units ordered by init time. |
| `systemd::analyze::criticalchain [unit]` | Boot critical chain. |
| `systemd::analyze::verify <unit-file>` | Verify a unit file's syntax. |

### Timedate

| Function | Purpose |
|---|---|
| `systemd::timedate::timezone` | Current timezone. |
| `systemd::timedate::settimezone <tz>` | Set timezone (root). |
| `systemd::timedate::time` | Current system time (RFC 3339). |
| `systemd::timedate::settime <time>` | Set system time (root). |
| `systemd::timedate::ntp` | NTP sync state. |
| `systemd::timedate::setntp <0\|1>` | Enable/disable NTP (root). |
| `systemd::timedate::localrtc` | RTC-in-local-time state. |
| `systemd::timedate::setlocalrtc <0\|1>` | Set RTC mode (root). |

### Hostname

| Function | Purpose |
|---|---|
| `systemd::hostname::get` | System hostname. |
| `systemd::hostname::set <hostname>` | Set hostname (root). |
| `systemd::hostname::chassis` | Chassis type. |
| `systemd::hostname::setchassis <chassis>` | Set chassis (root). |
| `systemd::hostname::icon` | Chassis icon name. |
| `systemd::hostname::seticon <icon>` | Set icon (root). |
| `systemd::hostname::deployment` | Deployment environment. |
| `systemd::hostname::setdeployment <env>` | Set deployment (root). |

**Compat note**: `hostnamectl`'s `show` subcommand was added in systemd
252; older builds only support per-field subcommands (`hostname`, `chassis`,
`icon-name`, `deployment`). We use the subcommand form throughout for
compatibility. We also avoid `--no-pager` since some older `hostnamectl`
builds reject it.

### Login

| Function | Purpose |
|---|---|
| `systemd::login::sessions` | List session IDs. |
| `systemd::login::sessioninfo <id>` | Session status as JSON. |
| `systemd::login::users` | List user IDs. |
| `systemd::login::seats` | List seat names. |
| `systemd::login::mysession` | Current session ID. |
| `systemd::login::locksession [id...]` | Lock sessions (no-arg = caller's). |
| `systemd::login::terminatesession <id...>` | Terminate sessions. |

Power actions (all require policy/root, all return immediately after
dispatching):

| Function | Wraps |
|---|---|
| `systemd::login::suspend` | `loginctl suspend` |
| `systemd::login::hibernate` | `loginctl hibernate` |
| `systemd::login::hybridsleep` | `loginctl hybrid-sleep` |
| `systemd::login::suspendthenhibernate` | `loginctl suspend-then-hibernate` |
| `systemd::login::poweroff` | `loginctl poweroff` |
| `systemd::login::reboot` | `loginctl reboot` |
| `systemd::login::halt` | `loginctl halt` |

### Machine (containers, VMs, hosts)

| Function | Purpose |
|---|---|
| `systemd::machine::list` | List running VMs/containers. |
| `systemd::machine::status <name>` | Status. |
| `systemd::machine::start <name>` | Start container as service. |
| `systemd::machine::poweroff <name...>` | Power off. |
| `systemd::machine::reboot <name...>` | Reboot. |
| `systemd::machine::terminate <name...>` | Force terminate. |
| `systemd::machine::kill <name> [signal]` | Send signal. |
| `systemd::machine::shell <name> [cmd...]` | Run shell/cmd in machine. |
| `systemd::machine::login <name>` | Get a login prompt. |

`shell` and `login` require an attached TTY; they error to stderr
otherwise.

### Run (transient units)

The `service` and `scope` functions are the workhorses. The `properties`,
`slice`, `env`, `onCalendar` helpers inject a single modifier and forward
to `service`. `timer` and `limits` are documented aliases (`timer` =
`onCalendar`, `limits` = `properties`) for grep-ability.

| Function | Purpose |
|---|---|
| `systemd::run::service [flags...] <cmd> [arg...]` | Run as transient service. |
| `systemd::run::scope [flags...] <cmd> [arg...]` | Run as transient scope. |
| `systemd::run::wait <cmd> [arg...]` | Run and block until done. |
| `systemd::run::properties <kv-list> <cmd> [arg...]` | Add `--property` flags. |
| `systemd::run::slice <slice> <cmd> [arg...]` | Pin to a cgroup slice. |
| `systemd::run::env <kv-list> <cmd> [arg...]` | Add `--setenv` flags. |
| `systemd::run::onCalendar <spec> <cmd> [arg...]` | Schedule via timer. |
| `systemd::run::timer <spec> <cmd> [arg...]` | Alias for `onCalendar`. |
| `systemd::run::limits <kv-list> <cmd> [arg...]` | Alias for `properties`. |

The kv-list format is space-separated `K=V K=V ...`. Quote individual
values for spaces: `K='value with spaces'`.

### Adjacent tools (intentional no-op stubs)

`systemd-resolve`, `systemd-cryptenroll`, `systemd-creds`,
`systemd-tmpfiles`, `systemd-sysext` are listed as `::call`-style
placeholders. They are **intentionally no-op**, not real implementations.
The shape:

```bash
systemd::resolve::call() {
    runtime::has_command systemd-resolve || {
        echo "systemd::resolve::call: requires systemd-resolve" >&2
        return 1
    }
    echo "systemd::resolve::call: stub, not yet implemented" >&2
    return 1
}
```

Purpose:

- The function name exists, so `compgen -A function | grep systemd::`
  lists it and documentation / autocomplete work
- The `runtime::has_command` guard documents the binary dependency
- The body is intentionally empty so a future session can expand each
  into a proper typed view
- The stderr message tells any caller that calling the stub is a no-op,
  rather than silently succeeding

Functions: `systemd::resolve::call`, `systemd::cryptenroll::call`,
`systemd::creds::call`, `systemd::tmpfiles::call`,
`systemd::sysext::call`.

---

## Naming conventions

Three-tier rule, applied consistently:

1. **Predicates** keep the underscore: `isactive`, `isfailed`, `ismasked`,
   `istemplate`, `isinstance`. Rationale: no clean way to express the
   "is it X?" semantics via `::` sub-namespace; the existing project
   convention (`fs::is_file`, `git::is_repo`, `runtime::is_ci`, ...) is
   `is_*` snake_case.
2. **Pure verbs** are single words: `start`, `stop`, `reload`, `mask`,
   `revert`, `enable`, `disable`, `cat`, `show`, `pid`, `status`, `field`.
3. **Compounds** camelcase, no prefix:
   - Verbs: `enablenow`, `tryrestart`, `reloadorrestart`, `daemonreload`,
     `listloaded`, `locksession`, `terminatesession`
   - Nouns: `localrtc`, `diskusage`, `sessioninfo`, `hybridsleep`,
     `suspendthenhibernate`
   - Reads (no verb): `timezone`, `chassis`, `icon`, `deployment`,
     `ntp`, `sessions`, `users`, `seats`, `boots`
   - Writes: `settimezone`, `settime`, `setntp`, `setlocalrtc`,
     `setchassis`, `seticon`, `setdeployment`
4. **Dropped prefixes**: `with_X` and `on_X` are redundant because the
   signature `<spec> <cmd>` makes the attachment implicit. So
   `systemd::run::properties`, `systemd::run::slice`, `systemd::run::env`,
   `systemd::run::limits` — no `with_` prefix.
5. **Preserved upstream term**: when systemd itself uses a compound name
   (`OnCalendar=`), the API name mirrors it verbatim:
   `systemd::run::onCalendar` keeps the capital `C` so `grep`-ing
   `man systemd.timer` finds it.

Bash-reserved-word exceptions:

- `until` is renamed to `untilnow` (compound) because `until` is a Bash
  reserved word and cannot be a function name.
- `type` is renamed to `chassis` (semantic rename) because `type` is a
  Bash builtin. Not used in this extension's public API, but mentioned
  for the broader naming pattern.

## Backward-compat shim

`src/process.sh:373-426` has 5 legacy helpers (`process::service::start`,
`::stop`, `::restart`, `::is_running`, `::is_enabled`). When this
extension is loaded, the shims delegate to `systemd::services::*`.
When the extension is not loaded, they fall back to `systemctl` (or
`service` for legacy init systems). New code should prefer the
`systemd::services::*` namespace.

---

## Common recipes

### Watch a service's journal (live tail)

```bash
systemd::journal::unit nginx -f
```

### Last 100 lines of a service's log, grep for "error"

```bash
systemd::journal::unit nginx -n 100 --no-tail | grep -i error
```

### Is my service healthy in a cron check?

```bash
if ! systemd::services::isactive myapp; then
    systemd::services::restart myapp
    echo "restarted myapp" | mail -s "alert" admin@example.com
fi
```

### Find why boot is slow

```bash
systemd::analyze::blame | head -10
```

### Schedule a one-shot command for 30 minutes from now

```bash
systemd::run::onCalendar "$(date -d '+30 min' '+%Y-%m-%d %H:%M:%S')" -- /path/to/backup.sh
```

### Schedule a recurring job (replacement for cron)

```bash
systemd::run::onCalendar "*-*-* 03:00:00" -- /path/to/nightly-job.sh
```

### Run a one-off command in a resource-limited cgroup

```bash
systemd::run::properties "CPUQuota=50% MemoryMax=500M LimitNOFILE=1024" -- my-heavy-task
```

### Toggle user/system scope

```bash
systemd::scope::set user
systemd::services::list          # user's units
systemd::scope::set system
systemd::services::list          # system units
```

### Get current hostname info as JSON

```bash
systemd::info | jq '{Hostname, Chassis, OperatingSystemPrettyName}'
```

### Check current session info

```bash
session=$(systemd::login::mysession)
systemd::login::sessioninfo "$session"
```

### Force reboot the machine

```bash
systemd::login::reboot
```

---

## Roadmap (future extensions)

- `systemd::timers` (typed view, similar pattern to `systemd::services`)
- `systemd::sockets` (typed view)
- `systemd::paths` (typed view)
- `systemd::mounts` (typed view)
- `systemd::targets` (typed view, read-only)
- Expansion of the 5 adjacent-tool stubs into proper typed views

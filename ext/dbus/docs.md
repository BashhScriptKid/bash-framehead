# ext/dbus — D-Bus client for bash-framehead

A Bash wrapper around `busctl` (preferred) and `gdbus` (fallback) for talking
to the system and session D-Buses from scripts. No Python, no compiled
helpers, no extra dependencies beyond what your system already ships.

## Dependencies

- **bash-framehead core**: `runtime`
- **External (one of)**: `busctl` (systemd) preferred, or `gdbus` (glib2) as fallback. Guard fails cleanly if neither is present.
- **For `dbus::subscribe`**: `pubsub` (core) is also loaded automatically.

## Usage

```bash
source ./bash-framehead.sh
source ./ext/dbus/dbus.sh
```

Backend is detected at source time. Override by setting `DBUS_BACKEND` to
`busctl` or `gdbus` before sourcing (not normally needed — autodetection
prefers busctl).

## Backend

Two backends supported:

- **`busctl`** (preferred): type-aware output, structured introspection, optional JSON. Ships with systemd.
- **`gdbus`**: nearly universal fallback on non-systemd systems. Shellier output.

Chosen at source time and stored in `_DBUS_BACKEND`. Some functions degrade
or fail on `gdbus` because not all `busctl` subcommands are mirrored.

## Buses

Two bus types supported, controllable per-shell:

- `session` — per-user, the common case for desktop integrations
- `system` — system-wide services (NetworkManager, login, etc.)

Default is `session`. Switch with `dbus::bus::set`:
```bash
dbus::bus::set system    # subsequent calls go to the system bus
dbus::bus::get           # echo current: "system"
```

## Output formats

Three distinct formats, each documented in the API:

**Raw busctl** (`::call`, `::get`, `::get::all`): one line per invocation,
`<sig> <values...>`. Example: `s "hello"`, `u 766`, `as 3 "a" "b" "c"`.
Empty return → empty output. Pipe through `dbus::fromsig` to parse.

**Annotated TSV** (`::list`, `::list::autostarts`): `<bus>\t<name>`, one
per line. The `::session`/`::system` variants drop the bus column.

**Signal TSV** (`::wait`, `::watch`, `::subscribe` payloads):
`<unix_ts>\t<sender>\t<path>\t<interface>\t<member>\t<sig>\t<args_json>`,
one record per line. Use `json::get` (or any JSON parser) on the trailing
field to pull out argument values.

## Examples

### Discovery

```bash
# What services are on each bus?
dbus::list
# session  :1.5
# session  org.freedesktop.Notifications
# system   org.freedesktop.systemd1
# ...

# Just the well-known names on the session bus
dbus::list::session | grep -v '^:'

# Resolve a well-known name to its unique connection ID
dbus::pinpoint org.freedesktop.Notifications
# :1.42

# Check if a name is currently claimed (exits 0 / 1)
dbus::owned org.freedesktop.DBus && echo "yes" || echo "no"
```

### Method calls

```bash
# Raw output: '<sig> <values...>'
dbus::call org.freedesktop.DBus /org/freedesktop/DBus \
    org.freedesktop.DBus GetId
# s "b55acd37f7d37e7e2e4a42259e77f98e"

# Parsed via ::fromsig
dbus::call org.freedesktop.DBus /org/freedesktop/DBus \
    org.freedesktop.DBus GetId | dbus::fromsig
# b55acd37f7d37e7e2e4a42259e77f98e

# Method with arguments
dbus::call org.freedesktop.DBus /org/freedesktop/DBus \
    org.freedesktop.DBus GetConnectionUnixProcessID s "org.freedesktop.DBus"
# u 766
dbus::call ... | dbus::fromsig
# 766
```

### Properties

```bash
# Read one property
dbus::get org.freedesktop.Notifications /org/freedesktop/Notifications \
    org.freedesktop.Notifications ServerInformation
# a{ss} 2 "name" "libnotify" "version" "0.8"

# Dump all properties on an interface
dbus::get::all org.freedesktop.DBus /org/freedesktop/DBus \
    org.freedesktop.DBus | dbus::fromsig
# Features	0
# Interfaces	1
# ...

# Write a property
dbus::set org.foo.Bar /com/example/Bar \
    org.freedesktop.DBus.Properties Version s "2.0"
```

### Introspection

```bash
# What interfaces does this object expose?
dbus::interfaces org.freedesktop.DBus /org/freedesktop/DBus
# org.freedesktop.DBus
# org.freedesktop.DBus.Introspectable
# org.freedesktop.DBus.Peer
# org.freedesktop.DBus.Properties
# ...

# What methods on a given interface?
dbus::methods org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus
# AddMatch
# GetId
# ...

# What signals can it emit?
dbus::signals org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus
# NameAcquired
# NameLost
# NameOwnerChanged

# What properties does it expose?
dbus::properties org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus
# Features
# Interfaces

# Raw introspection dump
dbus::introspect org.freedesktop.DBus /org/freedesktop/DBus
```

### Signals

```bash
# Wait for a signal (block until it arrives)
dbus::wait org.freedesktop.DBus NameOwnerChanged
# 1780417221	org.freedesktop.DBus	/org/freedesktop/DBus	org.freedesktop.DBus	NameOwnerChanged	sss	[":1.42","",":1.42"]

# With timeout
dbus::wait org.freedesktop.DBus NameOwnerChanged 5
# returns 124 if no signal in 5s

# Stream signals forever, pipe through a parser
dbus::watch org.freedesktop.DBus | while IFS=$'\t' read -r ts sender path iface member sig args; do
    printf '[%s] %s fired on %s: %s\n' "$ts" "$member" "$iface" "$args"
done

# Bridge into pubsub
pid=$(dbus::subscribe org.freedesktop.DBus NameOwnerChanged mytopic)
# ... signals now arrive on the mytopic pubsub topic ...
dbus::unsubscribe "$pid"
```

## API Reference

### Connection
- `dbus::bus::get` — echo current default bus ("session" or "system")
- `dbus::bus::set <session|system>` — set default bus for this shell

### Listing
- `dbus::list` — annotated merge: `<bus>\t<name>`, one per line
- `dbus::list::session` / `dbus::list::system` — bare names, one bus only
- `dbus::list::autostarts` — annotated merge of activatable services
- `dbus::list::autostarts::session` / `::system` — bare, one bus only

### Name resolution
- `dbus::pinpoint <name>` — well-known → unique connection name (e.g. `:1.42`)
- `dbus::owned <name>` — exit 0 if name is currently claimed, 1 otherwise

### Method calls
- `dbus::call <service> <path> <iface> <method> [sig] [args...]` — raw busctl output
- `dbus::fromsig` — parse sig-prefixed line(s) from stdin or argument

### Properties
- `dbus::get <service> <path> <iface> <property>` — single property, raw output
- `dbus::set <service> <path> <iface> <property> <sig> <value>` — write property
- `dbus::get::all <service> <path> <iface>` — dump all properties on interface

### Introspection
- `dbus::introspect <service> <path>` — raw structured dump
- `dbus::interfaces <service> <path>` — list interface names
- `dbus::methods <service> <path> <iface>` — list method names
- `dbus::signals <service> <path> <iface>` — list signal names
- `dbus::properties <service> <path> <iface>` — list property names

### Signals
- `dbus::wait <iface> <signal> [timeout_seconds]` — block for one, print TSV, exit
- `dbus::watch <iface> [signal]` — stream TSV records to stdout forever
- `dbus::subscribe <iface> <signal> <pubsub_topic>` — bridge into pubsub, returns PID
- `dbus::unsubscribe <pid>` — stop a bridge

## Sig parser (`dbus::fromsig`) — supported signatures

**v1 coverage:**

| Group | Sigs |
|---|---|
| Scalars | `y b n q i u x t d s o g` |
| Flat arrays of scalars | `as ao ay an aq ai au ax at ad` |
| Common dicts | `a{ss} a{si} a{su} a{sb} a{sd} a{so} a{sv}` |
| Structs | `(...)` with scalar elements |
| Variants | `v` (one level) |
| Multi-return | Multiple top-level types, e.g. `ss`, `siu` |

**Exotic / nested types** (e.g. `a(a{sv})`, deeply nested arrays of variants)
are emitted raw with a stderr warning. v1 covers the realistic 95%.

## Known limitations

- **macOS**: no `busctl` or `gdbus` on stock macOS. Extension is Linux-only.
  Use Apple's `osascript` or Swift/ObjC bridges there.
- **`gdbus` backend**: lacks structured subcommands. Some functions
  (`dbus::introspect`, `dbus::list::autostarts::session`) require `busctl`.
- **Cleanup of streaming commands**: `busctl monitor` sits in `read()` waiting
  for events, so `SIGPIPE` never propagates. `dbus::wait` and `dbus::subscribe`
  use `setsid` + process-group kill to ensure clean teardown.
  `dbus::watch` requires the caller to manage the pipe lifecycle.
- **JSON encoding of signal args**: best-effort for flat scalars; nested
  containers in variants may collapse to their count token. Use
  `dbus::call` + `dbus::fromsig` for precise parsing.

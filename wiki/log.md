# `log`

Structured logging with configurable severity levels, colourised output, and flexible routing. **10 functions** (5 public, 5 internal). No `::fast` variants.

---

## Configuration

Before using logging functions, configure the module by setting these variables (or call `log::init` to use defaults):

| Variable | Default | Description |
|----------|---------|-------------|
| `LOG_LEVEL` | `debug` | Minimum severity to emit (`debug`, `info`, `warn`, `error`, `fatal`) |
| `LOG_FMT` | `%timestamp% [%severity%] %message%` | Log line format with token substitution |
| `LOG_TIMESTAMP` | `%Y-%m-%d %H:%M:%S` | Timestamp format for log lines |
| `LOG_FILE` | (stdout) | File path to write logs to (defaults to stdout) |
| `LOG_COLOR` | `auto` | Colour mode: `on`, `off`, or `auto` (enabled only for terminals) |

```bash
# Initialize with defaults
log::init

# Or set custom configuration
LOG_LEVEL=info
LOG_FILE="/var/log/myapp.log"
LOG_FMT="[%severity%] %timestamp% — %message%"
```

## Severity Levels

| Function | Description |
|----------|-------------|
| `log::debug` | Debug message — typically suppressed in production |
| `log::info` | Informational message |
| `log::warn` | Warning — indicates something unexpected but recoverable |
| `log::error` | Error message — optionally exits with a given code |
| `log::fatal` | Fatal error — always exits (defaults to exit code 1) |

```bash
log::debug "Processing item #42"
log::info  "Server started on port 8080"
log::warn  "Rate limit approaching threshold"
log::error "Database connection failed" 5  # exits with code 5
log::fatal "Cannot start without config"    # exits with code 1
```

## Severity Bitmask

Severity levels use numeric values internally:

| Level | Bit |
|-------|-----|
| `debug` | 1 |
| `info`  | 2 |
| `warn`  | 4 |
| `error` | 8 |
| `fatal` | 16 |

Messages below `LOG_LEVEL` are suppressed. Setting `LOG_LEVEL=warn` suppresses `debug` and `info`.

## Format Tokens

The `LOG_FMT` string supports these substitution tokens:

| Token | Expands to |
|-------|------------|
| `%timestamp%` | Formatted timestamp (per `LOG_TIMESTAMP`) |
| `%severity%` | Uppercase severity label (DEBUG, INFO, WARN, ERROR, FATAL) |
| `%message%` | The log message text |
| `%caller_line%` | Line number of the call site |
| `%caller_func%` | Function name of the call site |

```bash
LOG_FMT="%timestamp% [%severity%] %caller_func%:%caller_line% — %message%"
log::error "Connection refused"
# → 2026-05-21 14:30:00 [ERROR] main:42 — Connection refused
```

## Colourisation

When `LOG_COLOR=auto` (the default), log output is colourised by severity when outputting to a terminal:

| Level | Colour |
|-------|--------|
| `debug` | Dim |
| `info`  | Default |
| `warn`  | Yellow |
| `error` | Red |
| `fatal` | Red + Bold |

Set `LOG_COLOR=off` for plain text (useful for file logging), or `LOG_COLOR=on` to force colour.

## Dependencies

- **Requires**: `runtime`
- **External tools**: None — pure Bash

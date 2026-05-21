# Getting Started

## What this is

bash-framehead is a runtime standard library for Bash. It's not a framework that owns your script — it's just a collection of functions you can call. Source one file, and you get string manipulation, math, filesystem operations, networking, colour, terminal control, process management, and more.

Yes, "library" and "Bash" in the same sentence is unusual. Bash scripts normally carry their own pile of one-off helpers, copy-pasted between projects and subtly different each time. bash-framehead is that pile, done once.

## Getting the file

The easiest way is to download the pre-compiled file from the [releases page](https://github.com/BashhScriptKid/bash-framehead/releases). The release asset is named `bash_framehead.sh` — no build step, no install. Drop it next to your script and source it.

```bash
curl -LO https://github.com/BashhScriptKid/bash-framehead/releases/latest/download/bash_framehead.sh
```

If you'd rather build from source or want a trimmed subset of modules, see [Compiling](compiling.md).

## Sourcing it

`source` runs the file in your current shell. Everything defined in the file — functions, variables, constants — becomes available to your script. Nothing executes on source; it only loads definitions.

Two common patterns for the source line:

```bash
# Absolute path — works anywhere, but script isn't portable
source /opt/bash-framehead/bash_framehead.sh

# Relative to the script's own location — portable
source "$(dirname "$0")/bash_framehead.sh"
```

Use the relative form if you're shipping the compiled file alongside your script. Use the absolute form for a system-wide install.

## Your first script

A script that checks for a required config file, prints a coloured status header, and exits. It uses `fs`, `colour`, and `string`:

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/bash_framehead.sh"

CONFIG="./app.conf"

# Build a styled header
header=$(colour::fg::bright_white)"$(string::upper "App Bootstrap")"$(colour::reset)
echo "$header"
echo ""

# Check for the config file
if fs::exists "$CONFIG"; then
    status=$(colour::fg::green)"FOUND"$(colour::reset)
    echo "  Config: $CONFIG ($status)"
else
    status=$(colour::fg::red)"MISSING"$(colour::reset)
    echo "  Config: $CONFIG ($status)"
    echo "  Create it first, then re-run."
    exit 1
fi

echo ""
echo "Ready."
```

## The naming convention

Every function follows `module::function`. The module name tells you what the function deals with — `string::upper`, `fs::exists`, `net::port::is_open`. Private helpers use `_module::function` — you'll see them in the source, but don't call them directly.

## What's included

| Module | What it does |
|--------|-------------|
| `runtime` | OS/arch detection, shell flags, environment introspection, privilege escalation |
| `string` | Case conversion, padding, splitting, encoding, validation, UUID, base64/32 |
| `fs` | Read/write, paths, find, checksums, temp files, symlinks, permissions |
| `array` | Slice, sort, filter, set ops, zip, chunk, rotate |
| `colour` | 4-bit, 8-bit, 24-bit colour, ANSI escapes, strip, wrap |
| `terminal` | Cursor, screen, shopt, colour detection, input |
| `math` | Integer and float arithmetic, trig, stats, unit conversion |
| `hash` | MD5, SHA*, HMAC, FNV, DJB2, CRC32, UUID5, slots |
| `timedate` | Dates, times, durations, timezones, calendars, stopwatch |
| `process` | Query, signal, lock, retry, timeout, jobs, services |
| `net` | IP, DNS, HTTP, interfaces, fetch, ping, port scan |
| `git` | Branch, commit, status, stash, tags, remotes |
| `hardware` | CPU, RAM, GPU, disk, battery, partitions |
| `device` | Block devices, loop, TTY, mount, filesystem |
| `random` | Native, LCG, xorshift, PCG32, xoshiro, ISAAC, WELL512 |
| `pm` | Package manager abstraction (apt/pacman/brew/dnf/...) |

Full function signatures and source live in the [API reference](../api/index.md).

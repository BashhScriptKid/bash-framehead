# Example: Structured Terminal Output

Uses `colour` and `terminal` to build a script that prints structured status output, hides the cursor while working, and always restores the terminal cleanly — even on Ctrl-C.

## Graceful colour degradation

Not every terminal supports colour, and a script running in a pipeline shouldn't spew ANSI escape codes into a log file. Check `terminal::is_tty` before using colour:

```bash
if terminal::is_tty; then
    ok="$(colour::fg::green)OK$(colour::reset)"
    warn="$(colour::fg::yellow)WARN$(colour::reset)"
    err="$(colour::fg::red)ERR$(colour::reset)"
else
    ok="OK"; warn="WARN"; err="ERR"
fi
```

If stdout is a terminal, you get colour. If it's piped to a file or another command, you get plain text. No escape-code garbage in your logs.

## Hiding the cursor

For scripts that do work between status lines, a blinking cursor jumping around is distracting. Hide it at the start, restore it on exit — even if the user hits Ctrl-C:

```bash
terminal::cursor::hide
trap 'terminal::cursor::show' EXIT INT
```

The trap on `INT` catches Ctrl-C. The trap on `EXIT` catches normal termination. The cursor comes back no matter what.

## Status lines with inline colour

For a line like "Checking disk space... OK" where the label is plain but the status tag is coloured, use `colour::wrap`:

```bash
status_tag() {
    case "$1" in
        ok)   colour::wrap 4 fg green "$1" ;;
        warn) colour::wrap 4 fg yellow "$1" ;;
        err)  colour::wrap 4 fg red "$1" ;;
    esac
}

check_disk() {
    printf "  Checking disk space... "
    local free
    free=$(hardware::partition::freeSpaceMB)
    if (( free < 1024 )); then
        echo "$(status_tag err) (${free}MB free)"
        return 1
    else
        echo "$(status_tag ok) (${free}MB free)"
    fi
}
```

## Drawing a separator

Use `terminal::width` to draw a line that spans the terminal:

```bash
separator() {
    local char="${1:--}"
    local w
    w=$(terminal::width 2>/dev/null || echo 80)
    printf '%*s\n' "$w" '' | tr ' ' "$char"
}
```

## The complete script

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/bash_framehead.sh"

# ---------- setup ----------
if terminal::is_tty; then
    ok="$(colour::fg::green)OK$(colour::reset)"
    warn="$(colour::fg::yellow)WARN$(colour::reset)"
    err="$(colour::fg::red)ERR$(colour::reset)"
    header_colour="$(colour::fg::bright_white)"
    reset="$(colour::reset)"
else
    ok="OK"; warn="WARN"; err="ERR"
    header_colour=""; reset=""
fi

terminal::cursor::hide
trap 'terminal::cursor::show' EXIT INT

separator() {
    local w
    w=$(terminal::width 2>/dev/null || echo 80)
    printf '%*s\n' "$w" '' | tr ' ' -
}

# ---------- header ----------
echo "${header_colour}System Health Check${reset}"
separator

# ---------- checks ----------
checks_passed=0
checks_total=0

run_check() {
    local label="$1"; shift
    (( checks_total++ ))
    printf "  %-40s " "$label"
    if "$@"; then
        echo "$ok"; (( checks_passed++ ))
    else
        echo "$err"
    fi
}

run_check "Disk space (>=1GB)" bash -c '
    (( $(hardware::partition::freeSpaceMB) >= 1024 ))
'

run_check "Required: git" runtime::has_command git
run_check "Required: curl" runtime::has_command curl

# ---------- summary ----------
separator
echo "${header_colour}Result:${reset} $checks_passed / $checks_total checks passed"

terminal::cursor::show
trap - EXIT INT
```

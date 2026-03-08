#!/usr/bin/env bash
# terminal.sh — bash-frameheader terminal lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# CAPABILITY DETECTION
# ==============================================================================

# Check if stdout is a terminal
terminal::is_tty() {
    [[ -t 1 ]]
}

# Check if stdin is a terminal
terminal::is_tty::stdin() {
    [[ -t 0 ]]
}

# Check if stderr is a terminal
terminal::is_tty::stderr() {
    [[ -t 2 ]]
}

# Get terminal width in columns
terminal::width() {
    tput cols 2>/dev/null || echo "80"
}

# Get terminal height in rows
terminal::height() {
    tput lines 2>/dev/null || echo "24"
}

# Get both as "cols rows"
terminal::size() {
    echo "$(terminal::width) $(terminal::height)"
}

# Check if terminal supports colours
terminal::has_colour() {
    [[ -t 1 ]] && (( $(tput colors 2>/dev/null) >= 8 ))
}

# Check if terminal supports 256 colours
terminal::has_256colour() {
    [[ -t 1 ]] && (( $(tput colors 2>/dev/null) >= 256 ))
}

# Check if terminal supports true colour
terminal::has_truecolour() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}

# Return the terminal emulator name if detectable
terminal::name() {
    if [[ -n "$TERM_PROGRAM" ]]; then
        echo "$TERM_PROGRAM"
    elif [[ -n "$TERMINAL" ]]; then
        echo "$TERMINAL"
    elif [[ -n "$TERM" ]]; then
        echo "$TERM"
    else
        echo "unknown"
    fi
}

# ==============================================================================
# CURSOR
# ==============================================================================

terminal::cursor::show() {
    printf '\033[?25h'
}

terminal::cursor::hide() {
    printf '\033[?25l'
}

terminal::cursor::toggle() {
    # Tracks state via a global flag
    if [[ "${_TERMINAL_CURSOR_HIDDEN:-0}" == "1" ]]; then
        terminal::cursor::show
        _TERMINAL_CURSOR_HIDDEN=0
    else
        terminal::cursor::hide
        _TERMINAL_CURSOR_HIDDEN=1
    fi
}

# Save cursor position
terminal::cursor::save() {
    printf '\033[s'
}

# Restore cursor to saved position
terminal::cursor::restore() {
    printf '\033[u'
}

# Move cursor to row, col (1-indexed)
# Usage: terminal::cursor::move row col
terminal::cursor::move() {
    printf '\033[%s;%sH' "$1" "$2"
}

# Move cursor up n rows
terminal::cursor::up() {
    printf '\033[%sA' "${1:-1}"
}

# Move cursor down n rows
terminal::cursor::down() {
    printf '\033[%sB' "${1:-1}"
}

# Move cursor right n cols
terminal::cursor::right() {
    printf '\033[%sC' "${1:-1}"
}

# Move cursor left n cols
terminal::cursor::left() {
    printf '\033[%sD' "${1:-1}"
}

# Move cursor to start of line n lines down
terminal::cursor::next_line() {
    printf '\033[%sE' "${1:-1}"
}

# Move cursor to start of line n lines up
terminal::cursor::prev_line() {
    printf '\033[%sF' "${1:-1}"
}

# Move cursor to column n on current line
terminal::cursor::col() {
    printf '\033[%sG' "${1:-1}"
}

# Move cursor to top-left (home)
terminal::cursor::home() {
    printf '\033[H'
}

# ==============================================================================
# SCREEN
# ==============================================================================

# Clear entire screen
terminal::clear() {
    printf '\033[2J'
    terminal::cursor::home
}

# Clear from cursor to end of screen
terminal::clear::to_end() {
    printf '\033[0J'
}

# Clear from cursor to beginning of screen
terminal::clear::to_start() {
    printf '\033[1J'
}

# Clear current line
terminal::clear::line() {
    printf '\033[2K'
}

# Clear from cursor to end of line
terminal::clear::line_end() {
    printf '\033[0K'
}

# Clear from cursor to start of line
terminal::clear::line_start() {
    printf '\033[1K'
}

# Enter alternate screen buffer (like vim/less do)
terminal::screen::alternate() {
    printf '\033[?1049h'
}

# Return to normal screen buffer
terminal::screen::normal() {
    printf '\033[?1049l'
}

# Enter alternate screen, run a command, return to normal screen
# Usage: terminal::screen::wrap command [args...]
terminal::screen::wrap() {
    terminal::screen::alternate
    "$@"
    local ret=$?
    terminal::screen::normal
    return $ret
}

terminal::screen::alternate_enter() {
    terminal::screen::alternate
    terminal::cursor::home
    terminal::clear
    trap 'terminal::screen::normal' EXIT INT TERM
}

terminal::screen::alternate_exit() {
    terminal::screen::normal
    trap - EXIT INT TERM
}

# Scroll up n lines
terminal::scroll::up() {
    printf '\033[%sS' "${1:-1}"
}

# Scroll down n lines
terminal::scroll::down() {
    printf '\033[%sT' "${1:-1}"
}

# Set terminal title (works in most modern terminal emulators)
# Usage: terminal::title "My Script"
terminal::title() {
    printf '\033]0;%s\007' "$1"
}

# Ring the terminal bell
terminal::bell() {
    printf '\007'
}

# ==============================================================================
# INPUT
# ==============================================================================

# Read a single keypress without requiring Enter
# Usage: terminal::read_key varname
terminal::read_key() {
    local _key
    IFS= read -r -s -n1 _key
    printf -v "$1" '%s' "$_key"
}

# Read a single keypress with a timeout
# Usage: terminal::read_key::timeout varname seconds
terminal::read_key::timeout() {
    local _key
    IFS= read -r -s -n1 -t "$2" _key
    printf -v "$1" '%s' "$_key"
}

# Prompt user for y/n, returns 0 for yes, 1 for no
# Usage: terminal::confirm "Are you sure?"
# Note: Will return 1 on non-'y' input (defaults to no)
terminal::confirm() {
    local prompt="${1:-Are you sure?} [y/N] "
    local key
    printf '%s' "$prompt"
    terminal::read_key key
    printf '\n'
    [[ "${key,,}" == "y" ]]
}

# Prompt with a default choice shown
# Usage: terminal::confirm::default yes "Proceed?"
terminal::confirm::default() {
    local default="${1:-yes}" prompt="${2:-Are you sure?}"
    local label
    [[ "$default" == "yes" ]] && label="[Y/n]" || label="[y/N]"
    printf '%s %s ' "$prompt" "$label"
    local key
    terminal::read_key key
    printf '\n'
    if [[ -z "$key" ]]; then
        [[ "$default" == "yes" ]]
    else
        [[ "${key,,}" == "y" ]]
    fi
}

# Disable terminal echo (e.g. for password input)
terminal::echo::off() {
    stty -echo 2>/dev/null
}

# Re-enable terminal echo
terminal::echo::on() {
    stty echo 2>/dev/null
}

# Read a password (no echo)
# Usage: terminal::read_password varname [prompt]
terminal::read_password() {
    local _pass
    printf '%s' "${2:-Password: }"
    terminal::echo::off
    IFS= read -r _pass
    terminal::echo::on
    printf '\n'
    printf -v "$1" '%s' "$_pass"
}

# ==============================================================================
# SHOPT WRAPPERS
# Convenience wrappers around bash's shopt builtin
# ==============================================================================

# Enable a shopt option, return 1 if unsupported
terminal::shopt::enable() {
    shopt -s "$1" 2>/dev/null
}

# Disable a shopt option
terminal::shopt::disable() {
    shopt -u "$1" 2>/dev/null
}

# Check if a shopt option is enabled
terminal::shopt::is_enabled() {
    shopt -q "$1" 2>/dev/null
}

# Get current value of a shopt option ("on" or "off")
terminal::shopt::get() {
    shopt "$1" 2>/dev/null | awk '{print $2}'
}

# List all enabled shopt options
terminal::shopt::list::enabled() {
    shopt | awk '$2 == "on" {print $1}'
}

# List all disabled shopt options
terminal::shopt::list::disabled() {
    shopt | awk '$2 == "off" {print $1}'
}

# Save current shopt state (prints a restore command)
# Usage: eval "$(terminal::shopt::save)"
terminal::shopt::save() {
    shopt | awk '$2 == "on"  {print "shopt -s " $1 ";"}'
    shopt | awk '$2 == "off" {print "shopt -u " $1 ";"}'
}

# Restore state from a variable
# Usage: terminal::shopt::load varname
terminal::shopt::load() {
    local _var="${1:-_SHOPT_STATE}"
    eval "${!_var}"
}

# Common shopt convenience toggles
terminal::shopt::globstar::enable()      { shopt -s globstar     2>/dev/null; }  # ** recursive glob
terminal::shopt::globstar::disable()     { shopt -u globstar     2>/dev/null; }
terminal::shopt::nullglob::enable()      { shopt -s nullglob     2>/dev/null; }  # failed globs → empty
terminal::shopt::nullglob::disable()     { shopt -u nullglob     2>/dev/null; }
terminal::shopt::dotglob::enable()       { shopt -s dotglob      2>/dev/null; }  # globs match dotfiles
terminal::shopt::dotglob::disable()      { shopt -u dotglob      2>/dev/null; }
terminal::shopt::extglob::enable()       { shopt -s extglob      2>/dev/null; }  # extended patterns
terminal::shopt::extglob::disable()      { shopt -u extglob      2>/dev/null; }
terminal::shopt::nocaseglob::enable()    { shopt -s nocaseglob   2>/dev/null; }  # case-insensitive glob
terminal::shopt::nocaseglob::disable()   { shopt -u nocaseglob   2>/dev/null; }
terminal::shopt::autocd::enable()        { shopt -s autocd       2>/dev/null; }  # cd by typing dir name
terminal::shopt::autocd::disable()       { shopt -u autocd       2>/dev/null; }
terminal::shopt::checkwinsize::enable()  { shopt -s checkwinsize 2>/dev/null; }  # update LINES/COLUMNS
terminal::shopt::checkwinsize::disable() { shopt -u checkwinsize 2>/dev/null; }
terminal::shopt::histappend::enable()    { shopt -s histappend   2>/dev/null; }  # append to history
terminal::shopt::histappend::disable()   { shopt -u histappend   2>/dev/null; }
terminal::shopt::cdspell::enable()       { shopt -s cdspell      2>/dev/null; }  # autocorrect cd typos
terminal::shopt::cdspell::disable()      { shopt -u cdspell      2>/dev/null; }
terminal::shopt::nocasematch::enable()   { shopt -s nocasematch  2>/dev/null; }  # case-insensitive [[ =~
terminal::shopt::nocasematch::disable()  { shopt -u nocasematch  2>/dev/null; }

#!/usr/bin/env bash
# colour.sh — bash-frameheader colour lib
# Requires: runtime.sh (runtime::has_command)
#
# THREE COLOUR DEPTHS:
#   4-bit  — 16 colours (black, red, green, yellow, blue, magenta, cyan, white + bright variants)
#   8-bit  — 256 colours (16 named + 216 RGB cube + 24 greyscale)
#   24-bit — 16 million colours (true colour, R,G,B 0-255 each)
#
# COLOUR NAMES (4-bit and 8-bit):
#   black, red, green, yellow, blue, magenta, cyan, white
#   Prefix with "bright" for bright variants: "bright red", "brightred"
#
# 8-BIT RGB CUBE: rgb0,0,0 to rgb5,5,5 (or bare R,G,B without prefix)
# 8-BIT GREYSCALE: grey0 to grey23 (or gray0 to gray23)
#
# 24-BIT RGB: R,G,B where each is 0-255

# ==============================================================================
# CAPABILITY DETECTION
# ==============================================================================

# Check if the terminal supports any colour output.
# Use this as a guard before applying escape codes — prevents raw escape
# sequences from leaking into pipes, log files, or non-interactive shells.
#
# Usage: colour::supports
#   if colour::supports; then colour::println 4 fg red "Error!"; fi
#
# Returns: 0 if stdout is a terminal and reports at least 8 colours, 1 otherwise
#
# Note: Returns 1 when stdout is redirected (e.g. piped to a file), even if
# the terminal itself would support colour.
colour::supports() {
    [[ -t 1 ]] || return 1
    local count
    count=$(colour::depth)
    (( count >= 8 ))
}

# Return the number of colours the terminal supports as reported by tput.
# Use this when you need to branch on colour depth rather than just checking
# a specific threshold — e.g. to pick the richest mode the terminal can handle.
#
# Usage: colour::depth
#   depth=$(colour::depth)
#
# Returns: echoes the colour count (typically 8, 256, or 16777216); echoes 0
# if tput is unavailable or the terminal reports no colour support
colour::depth() {
    tput colors 2>/dev/null || echo "0"
}

# Check if the terminal supports 256 colours (8-bit mode).
# Use this before using the RGB cube or greyscale ranges with colour::esc 8.
#
# Usage: colour::supports_256
#   if colour::supports_256; then colour::esc 8 fg "rgb3,2,1"; fi
#
# Returns: 0 if 256+ colours are available, 1 otherwise
colour::supports_256() {
    (( $(colour::depth) >= 256 ))
}

# Check if the terminal supports true colour (24-bit, ~16 million colours).
# Use this before passing full R,G,B values to colour::esc 24. Most modern
# terminal emulators set $COLORTERM to signal this capability.
#
# Usage: colour::supports_truecolor
#   if colour::supports_truecolor; then colour::esc 24 fg "255,128,0"; fi
#
# Returns: 0 if $COLORTERM is "truecolor" or "24bit", 1 otherwise
#
# Note: Relies entirely on the $COLORTERM environment variable. Terminals that
# support true colour but don't set this variable will return 1.
colour::supports_truecolor() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}

# ==============================================================================
# INDEX LOOKUP
# Internal helpers — returns the numeric colour index for use in escape codes
# ==============================================================================

# Resolve a colour name to its 4-bit ANSI code number for use in escape sequences.
# This is an internal helper called by colour::esc — you typically won't call it directly.
#
# Usage: colour::index::4bit colour_name [fg|bg]
#   colour::index::4bit "bright red" fg
#   colour::index::4bit "blue" bg
#
# Returns: echoes the ANSI code number (30–37 fg, 40–47 bg, 90–97 bright fg,
# 100–107 bright bg); returns 1 for unrecognised colour names
#
# Note: Input is case-insensitive. Accepts "bright red" or "brightred" for bright variants.
colour::index::4bit() {
    local key="${1,,}" fg_bg="${2:-fg}"

    # Handle bright prefix — "bright red" or "brightred"
    local is_bright=0
    if [[ "$key" == bright* ]]; then
        is_bright=1
        key="${key#bright}"
        key="${key# }"  # strip optional space
    fi

    local val
    case "$key" in
        black)   val=30 ;;
        red)     val=31 ;;
        green)   val=32 ;;
        yellow)  val=33 ;;
        blue)    val=34 ;;
        magenta) val=35 ;;
        cyan)    val=36 ;;
        white)   val=37 ;;
        *)       return 1 ;;
    esac

    (( is_bright )) && val=$(( val + 60 ))
    [[ "$fg_bg" == "bg" ]] && val=$(( val + 10 ))

    echo "$val"
}

# Resolve a colour name or value to its 8-bit palette index (0–255).
# This is an internal helper called by colour::esc — you typically won't call it directly.
#
# Usage: colour::index::8bit colour_name
#   colour::index::8bit "bright cyan"
#   colour::index::8bit "rgb3,2,1"
#   colour::index::8bit "grey12"
#
# Returns: echoes the palette index (0–255); returns 1 for unrecognised input
#
# Note: Accepts named colours (0–7), bright named colours (8–15), RGB cube values
# in the format rgb0,0,0–rgb5,5,5 or bare 0,0,0–5,5,5, and greyscale as grey0–grey23
# or gray0–gray23. The "bright" prefix is silently ignored for RGB inputs.
colour::index::8bit() {
    local key="${1,,}"

    # Handle bright prefix
    local is_bright=0
    if [[ "$key" == bright* ]]; then
        is_bright=1
        key="${key#bright}"
        key="${key# }"
    fi

    # Named colours (0-7, or 8-15 if bright)
    local val=-1
    case "$key" in
        black)   val=0 ;;
        red)     val=1 ;;
        green)   val=2 ;;
        yellow)  val=3 ;;
        blue)    val=4 ;;
        magenta) val=5 ;;
        cyan)    val=6 ;;
        white)   val=7 ;;
    esac

    if (( val >= 0 )); then
        (( is_bright )) && val=$(( val + 8 ))
        echo "$val"
        return 0
    fi

    # RGB cube (16-231): rgb0,0,0 to rgb5,5,5 or bare R,G,B
    if [[ "$key" =~ ^(rgb)?([0-5]),([0-5]),([0-5])$ ]]; then
        local r="${BASH_REMATCH[2]}" g="${BASH_REMATCH[3]}" b="${BASH_REMATCH[4]}"
        (( is_bright )) && echo "colour::index::8bit: bright ignored for RGB" >&2
        echo $(( 16 + r * 36 + g * 6 + b ))
        return 0
    fi

    # Greyscale (232-255): grey0-grey23 or gray0-gray23
    if [[ "$key" =~ ^(gr[ae]y)?([0-9]+)$ ]]; then
        local n="${BASH_REMATCH[2]}"
        # Warn on bare numbers — ambiguous intent
        [[ "$key" =~ ^[0-9]+$ ]] && \
            echo "colour::index::8bit: bare number interpreted as greyscale index" >&2
        (( n >= 0 && n <= 23 )) || { echo "colour::index::8bit: greyscale index must be 0-23" >&2; return 1; }
        echo $(( 232 + n ))
        return 0
    fi

    echo "colour::index::8bit: unrecognised colour '${1}'" >&2
    return 1
}

# ==============================================================================
# ESCAPE CODE GENERATION
# ==============================================================================

# Generate a raw ANSI escape sequence for a given colour and depth.
# Use this when you need the raw escape code to embed in a string or pass to
# printf directly. For printing coloured text, colour::print or colour::wrap
# are usually more convenient.
#
# Usage: colour::esc bit fg_bg colour
#   colour::esc 4 fg "bright red"
#   colour::esc 8 bg "rgb2,4,1"
#   colour::esc 24 fg "255,128,0"
#
# Returns: prints the escape sequence to stdout; returns 1 on invalid input
#
# Note: bit must be 4, 8, or 24. fg_bg must be "fg" or "bg". 24-bit values
# are clamped to 0–255 per channel automatically.
colour::esc() {
    local bit="${1:-}" fg_bg="${2:-fg}"; shift 2
    [[ -n "$bit" ]] || return 1

    case "$bit" in
    4)
        local index
        index=$(colour::index::4bit "$*" "$fg_bg") || return 1
        printf '\033[%sm' "$index"
        ;;
    8)
        local index
        index=$(colour::index::8bit "$*") || return 1
        if [[ "$fg_bg" == "bg" ]]; then
            printf '\033[48;5;%sm' "$index"
        else
            printf '\033[38;5;%sm' "$index"
        fi
        ;;
    24)
        local r g b
        if [[ "$1" =~ ^(rgb)?([0-9]+),([0-9]+),([0-9]+)$ ]]; then
            r="${BASH_REMATCH[2]}"
            g="${BASH_REMATCH[3]}"
            b="${BASH_REMATCH[4]}"
        else
            echo "colour::esc: 24-bit expects R,G,B format" >&2
            return 1
        fi
        # Clamp to 0-255
        (( r = r > 255 ? 255 : r ))
        (( g = g > 255 ? 255 : g ))
        (( b = b > 255 ? 255 : b ))
        if [[ "$fg_bg" == "bg" ]]; then
            printf '\033[48;2;%s;%s;%sm' "$r" "$g" "$b"
        else
            printf '\033[38;2;%s;%s;%sm' "$r" "$g" "$b"
        fi
        ;;
    *)
        echo "colour::esc: bit depth must be 4, 8, or 24" >&2
        return 1
        ;;
    esac
}

# ==============================================================================
# ATTRIBUTES
# Text styling — not colour-depth dependent
# ==============================================================================

# Emit the ANSI escape code for the named text attribute.
# These functions print nothing visible — they change how subsequent text is rendered
# until colour::reset (or the matching colour::reset::* function) is called.
# Use them when building coloured output with printf or in PS1 prompts.
#
# Usage: colour::bold; printf "important"; colour::reset
#   colour::underline; printf "heading"; colour::reset::underline
#
# Returns: prints the escape sequence to stdout; always returns 0
#
# Note: colour::blink and colour::hidden have inconsistent support across
# terminals — blink is often disabled by default, hidden varies by emulator.
colour::reset()     { printf '\033[0m';  }
colour::bold()      { printf '\033[1m';  }
colour::dim()       { printf '\033[2m';  }
colour::italic()    { printf '\033[3m';  }
colour::underline() { printf '\033[4m';  }
colour::blink()     { printf '\033[5m';  }
colour::reverse()   { printf '\033[7m';  }
colour::hidden()    { printf '\033[8m';  }
colour::strike()    { printf '\033[9m';  }

# Reset a single text attribute without affecting others.
# Use these instead of colour::reset when you want to turn off one style
# (e.g. stop underlining) while keeping other active attributes like colour.
#
# Usage: colour::reset::underline
#   colour::reset::fg    # reset foreground colour only
#   colour::reset::bg    # reset background colour only
#
# Returns: prints the escape sequence to stdout; always returns 0
#
# Note: colour::reset::bold and colour::reset::dim share the same escape code
# (ESC[22m) — resetting one resets both.
# Reset individual attributes
colour::reset::bold()      { printf '\033[22m'; }
colour::reset::dim()       { printf '\033[22m'; }
colour::reset::italic()    { printf '\033[23m'; }
colour::reset::underline() { printf '\033[24m'; }
colour::reset::blink()     { printf '\033[25m'; }
colour::reset::reverse()   { printf '\033[27m'; }
colour::reset::hidden()    { printf '\033[28m'; }
colour::reset::strike()    { printf '\033[29m'; }
colour::reset::fg()        { printf '\033[39m'; }
colour::reset::bg()        { printf '\033[49m'; }

# ==============================================================================
# CONVENIENCE — 4-BIT NAMED SHORTCUTS
# colour::fg::red, colour::bg::bright_blue etc.
# ==============================================================================

# Set the foreground (text) colour using a named 4-bit shortcut.
# Use these for the most portable colour output — 4-bit colours work in
# virtually every terminal. Call colour::reset or colour::reset::fg when done.
#
# Usage: colour::fg::red; printf "error"; colour::reset
#
# Returns: prints the escape sequence to stdout; always returns 0
# Foreground
colour::fg::black()          { printf '\033[30m'; }
colour::fg::red()            { printf '\033[31m'; }
colour::fg::green()          { printf '\033[32m'; }
colour::fg::yellow()         { printf '\033[33m'; }
colour::fg::blue()           { printf '\033[34m'; }
colour::fg::magenta()        { printf '\033[35m'; }
colour::fg::cyan()           { printf '\033[36m'; }
colour::fg::white()          { printf '\033[37m'; }
colour::fg::bright_black()   { printf '\033[90m'; }
colour::fg::bright_red()     { printf '\033[91m'; }
colour::fg::bright_green()   { printf '\033[92m'; }
colour::fg::bright_yellow()  { printf '\033[93m'; }
colour::fg::bright_blue()    { printf '\033[94m'; }
colour::fg::bright_magenta() { printf '\033[95m'; }
colour::fg::bright_cyan()    { printf '\033[96m'; }
colour::fg::bright_white()   { printf '\033[97m'; }

# Set the background colour using a named 4-bit shortcut.
# Use these to highlight text or create status indicators. Call colour::reset
# or colour::reset::bg to restore the default background.
#
# Usage: colour::bg::yellow; colour::fg::black; printf " WARN "; colour::reset
#
# Returns: prints the escape sequence to stdout; always returns 0
# Background
colour::bg::black()          { printf '\033[40m';  }
colour::bg::red()            { printf '\033[41m';  }
colour::bg::green()          { printf '\033[42m';  }
colour::bg::yellow()         { printf '\033[43m';  }
colour::bg::blue()           { printf '\033[44m';  }
colour::bg::magenta()        { printf '\033[45m';  }
colour::bg::cyan()           { printf '\033[46m';  }
colour::bg::white()          { printf '\033[47m';  }
colour::bg::bright_black()   { printf '\033[100m'; }
colour::bg::bright_red()     { printf '\033[101m'; }
colour::bg::bright_green()   { printf '\033[102m'; }
colour::bg::bright_yellow()  { printf '\033[103m'; }
colour::bg::bright_blue()    { printf '\033[104m'; }
colour::bg::bright_magenta() { printf '\033[105m'; }
colour::bg::bright_cyan()    { printf '\033[106m'; }
colour::bg::bright_white()   { printf '\033[107m'; }

# ==============================================================================
# HIGHER-LEVEL HELPERS
# ==============================================================================

# Print text in a given colour, then automatically reset to default.
# This is the go-to function for simple one-off coloured output — it handles
# the escape/reset sandwich for you.
#
# Usage: colour::print bit fg_bg colour text
#   colour::print 4 fg red "Error: file not found"
#   colour::print 8 fg "rgb4,2,0" "Warning"
#
# Returns: prints coloured text to stdout; returns 0
#
# Note: Prints without a trailing newline. Use colour::println for a newline.
colour::print() {
    local bit="$1" fg_bg="$2" col="$3" text="$4"
    colour::esc "$bit" "$fg_bg" "$col"
    printf '%s' "$text"
    colour::reset
}

# Print text in a given colour followed by a newline, then reset.
# Identical to colour::print but adds a newline — the most common case
# for status messages, log lines, and banner output.
#
# Usage: colour::println bit fg_bg colour text
#   colour::println 4 fg green "Done."
#
# Returns: prints coloured text with a trailing newline; returns 0
colour::println() {
    colour::print "$@"
    printf '\n'
}

# Wrap text in colour escape codes and return the result as a string.
# Use this when you need a coloured string to embed inside a larger message
# or variable, rather than printing it directly.
#
# Usage: colour::wrap bit fg_bg colour text
#   label=$(colour::wrap 4 fg cyan "INFO")
#   echo "[$label] server started"
#
# Returns: echoes the escape-wrapped string; returns 0
colour::wrap() {
    local bit="$1" fg_bg="$2" col="$3" text="$4"
    printf '%s%s%s' "$(colour::esc "$bit" "$fg_bg" "$col")" "$text" "$(colour::reset)"
}

# Remove all ANSI escape codes from a string, leaving only plain text.
# Use this before writing coloured output to a log file, comparing strings,
# or passing text to tools that don't understand escape sequences.
#
# Usage: colour::strip text
#   plain=$(colour::strip "$coloured_line")
#
# Returns: echoes the cleaned string; returns 0
colour::strip() {
    echo "$1" | sed 's/\x1b\[[0-9;]*[mGKHF]//g'
}

# Return the visible character length of a string, ignoring any ANSI escape codes.
# Use this when calculating padding or column alignment for coloured output,
# since ${#string} counts escape code bytes and gives wrong results.
#
# Usage: colour::visible_length text
#   len=$(colour::visible_length "$coloured_label")
#   printf "%-${len}s\n" "$coloured_label"
#
# Returns: echoes the visible character count as an integer; returns 0
colour::visible_length() {
    local stripped
    stripped=$(colour::strip "$1")
    echo "${#stripped}"
}

# Check whether a string contains any ANSI escape codes.
# Use this to decide whether to strip a string before further processing,
# or to detect if upstream output is already coloured.
#
# Usage: colour::has_colour text
#   if colour::has_colour "$line"; then colour::strip "$line"; fi
#
# Returns: 0 if escape codes are present, 1 if the string is plain text
colour::has_colour() {
    [[ "$1" =~ $'\033'\[ ]]
}

# Generate an escape sequence only if the terminal supports the requested depth.
# Use this instead of colour::esc when writing portable scripts — it gracefully
# degrades to a no-op rather than printing raw codes to unsupported terminals.
#
# Usage: colour::safe_esc bit fg_bg colour
#   colour::safe_esc 24 fg "255,100,0"   # no-op if true colour unsupported
#   colour::safe_esc 4 fg red             # safe for virtually any terminal
#
# Returns: prints the escape sequence if supported; prints nothing and returns 0
# if the terminal lacks the required depth
colour::safe_esc() {
    local bit="$1"
    case "$bit" in
    4)  colour::supports     || return 0 ;;
    8)  colour::supports_256 || return 0 ;;
    24) colour::supports_truecolor || return 0 ;;
    esac
    colour::esc "$@"
}

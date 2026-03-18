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

# Check if the terminal supports any colour
colour::supports() {
    [[ -t 1 ]] || return 1
    local count
    count=$(colour::depth)
    (( count >= 8 ))
}

# Return the number of colours the terminal supports
colour::depth() {
    tput colors 2>/dev/null || echo "0"
}

# Check if terminal supports 256 colours
colour::supports_256() {
    (( $(colour::depth) >= 256 ))
}

# Check if terminal supports true colour (24-bit)
# Checks $COLORTERM env var — set by most modern terminals
colour::supports_truecolor() {
    [[ "$COLORTERM" == "truecolor" || "$COLORTERM" == "24bit" ]]
}

# ==============================================================================
# INDEX LOOKUP
# Internal helpers — returns the numeric colour index for use in escape codes
# ==============================================================================

# Get 4-bit ANSI colour code index
# Usage: colour::index::4bit colour_name [fg|bg]
# Returns: ANSI code number (30-37, 40-47, 90-97, 100-107)
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

# Get 8-bit colour index (0-255)
# Usage: colour::index::8bit colour_name
# Accepts: named colours, "bright name", "rgbR,G,B", "greyN"/"grayN"
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

# Generate a raw ANSI escape sequence
# Usage: colour::esc bit fg_bg colour [colour...]
#   bit    — 4, 8, or 24
#   fg_bg  — fg or bg
#   colour — colour name/value (see header for formats)
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

colour::reset()     { printf '\033[0m';  }
colour::bold()      { printf '\033[1m';  }
colour::dim()       { printf '\033[2m';  }
colour::italic()    { printf '\033[3m';  }
colour::underline() { printf '\033[4m';  }
colour::blink()     { printf '\033[5m';  }
colour::reverse()   { printf '\033[7m';  }
colour::hidden()    { printf '\033[8m';  }
colour::strike()    { printf '\033[9m';  }

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

# Print text wrapped in colour, auto-reset after
# Usage: colour::print bit fg_bg colour text
#        echo "text" | colour::print bit fg_bg colour
colour::print() {
  local bit="$1" fg_bg="$2" col="$3" text
  if [[ ! -t 0 ]]; then text=$(cat); else text="$4"; fi
  colour::esc "$bit" "$fg_bg" "$col"
  printf '%s' "$text"
  colour::reset
}

# Print text in colour followed by newline
colour::println() {
  colour::print "$@"
  printf '\n'
}

# Wrap text in escape codes and return as string (no direct print)
# Usage: colour::wrap bit fg_bg colour text
#        echo "text" | colour::wrap bit fg_bg colour
colour::wrap() {
  local bit="$1" fg_bg="$2" col="$3" text
  if [[ ! -t 0 ]]; then text=$(cat); else text="$4"; fi
  printf '%s%s%s' "$(colour::esc "$bit" "$fg_bg" "$col")" "$text" "$(colour::reset)"
}

# Strip all ANSI escape codes from a string
# Usage: colour::strip text
#        echo "text" | colour::strip
colour::strip() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; fi
  printf '%s\n' "$input" | sed 's/\x1b\[[0-9;]*[mGKHF]//g'
}

# Return the visible length of a string (excluding escape codes)
# Useful for padding/alignment with coloured strings
colour::visible_length() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; fi
  local stripped
  stripped=$(colour::strip "$input")
  echo "${#stripped}"
}

# Check if a string contains any ANSI escape codes
colour::has_colour() {
  local input
  if [[ ! -t 0 ]]; then input=$(cat); else input="$1"; fi
  [[ "$input" =~ $'\033'\[ ]]
}

# Gracefully degrade — return escape code only if terminal supports the depth
# Usage: colour::safe_esc bit fg_bg colour
# Returns empty string (no-op) if terminal doesn't support the requested depth
colour::safe_esc() {
    local bit="$1"
    case "$bit" in
    4)  colour::supports     || return 0 ;;
    8)  colour::supports_256 || return 0 ;;
    24) colour::supports_truecolor || return 0 ;;
    esac
    colour::esc "$@"
}

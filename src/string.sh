#!/usr/bin/env bash
# string.sh — bash-frameheader string lib
# Pure bash where possible — no external tools unless noted.

# ==============================================================================
# INSPECTION
# ==============================================================================

# Length of a string
# Usage: string::length str
string::length() {
  echo "${#1}"
}

# Check if string is empty
string::is_empty() {
  [[ -z "$1" ]]
}

# Check if string is non-empty
string::is_not_empty() {
  [[ -n "$1" ]]
}

# Check if string contains substring
# Usage: string::contains haystack needle
string::contains() {
  [[ "$1" == *"$2"* ]]
}

# Check if string starts with prefix
# Usage: string::starts_with str prefix
string::starts_with() {
  [[ "$1" == "$2"* ]]
}

# Check if string ends with suffix
# Usage: string::ends_with str suffix
string::ends_with() {
  [[ "$1" == *"$2" ]]
}

# Check if string matches a regex
# Usage: string::matches str regex
string::matches() {
  [[ "$1" =~ $2 ]]
}

# Check if string is a valid integer
string::is_integer() {
  [[ "$1" =~ ^-?[0-9]+$ ]]
}

# Check if string is a valid float
string::is_float() {
  [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?([Ee][+-]?[0-9]+)?$ ]]
}

string::is_hex() {
  [[ "$1" =~ ^(0[xX])?[0-9A-Fa-f]+$ ]]
}

string::is_bin() {
  [[ "$1" =~ ^0b[01]+$ ]]
}

string::is_octal() {
  [[ "$1" =~ ^0[0-7]+$ ]]
}

string::is_numeric() {
  # accepts int, float, hex, binary, octal
  string::is_integer "$1" || string::is_float "$1" ||
    string::is_hex "$1" || string::is_bin "$1" ||
    string::is_octal "$1"
}

# Check if string is alphanumeric only
string::is_alnum() {
  [[ "$1" =~ ^[a-zA-Z0-9]+$ ]]
}

# Check if string is alphabetic only
string::is_alpha() {
  [[ "$1" =~ ^[a-zA-Z]+$ ]]
}

# ==============================================================================
# CASE
# ==============================================================================

# Convert to uppercase
string::upper() {
  echo "${1^^}"
}

# Convert to uppercase (Bash 3 compatible)
string::upper::legacy() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Convert to lowercase
string::lower() {
  echo "${1,,}"
}

# Convert to lowercase (Bash 3 compatible)
string::lower::legacy() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Capitalise first character only
string::capitalise() {
  echo "${1^}"
}

# Capitalise first character (Bash 3 compatible)
string::capitalise::legacy() {
  local s="$1"
  echo "$(echo "${s:0:1}" | tr '[:lower:]' '[:upper:]')${s:1}"
}

# Convert to title case (capitalise first letter of each word)
# Requires: awk
string::title() {
  echo "$1" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2)); print}'
}

# ==============================================================================
# NAMING CONVENTION CONVERSION
#
# Naming matrix — all pairwise conversions:
#
#   plain    → space-separated words  "hello world"
#   snake    → underscore_separated   "hello_world"
#   kebab    → hyphen-separated       "hello-world"
#   camel    → camelCase              "helloWorld"
#   pascal   → PascalCase             "HelloWorld"
#   constant → SCREAMING_SNAKE        "HELLO_WORLD"
#   dot      → dot.separated          "hello.world"
#   path     → slash/separated        "hello/world"
#
# Conversion helpers — split any known format into words array
# then reassemble into target format.
# ==============================================================================

# Internal: split any common convention into space-separated words (lowercase)
_string::to_words() {
  local s="$1"
  # Insert space before uppercase runs (camel/pascal → words)
  s="$(echo "$s" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')"
  # Replace common separators with spaces
  s="${s//_/ }"
  s="${s//-/ }"
  s="${s//./ }"
  s="${s//\// }"
  # Lowercase everything
  echo "${s,,}"
}

# plain (space-separated) → snake_case
# Usage: string::plain_to_snake "hello world" → "hello_world"
string::plain_to_snake() {
  local s="${1// /_}"
  echo "${s,,}"
}

# plain → kebab-case
string::plain_to_kebab() {
  local s="${1// /-}"
  echo "${s,,}"
}

# plain → camelCase
string::plain_to_camel() {
  local result="" first=true
  for word in $1; do
    if $first; then
      result+="${word,,}"
      first=false
    else result+="${word^}"; fi
  done
  echo "$result"
}

# plain → PascalCase
string::plain_to_pascal() {
  local result=""
  for word in $1; do result+="${word^}"; done
  echo "$result"
}

# plain → CONSTANT_CASE
string::plain_to_constant() {
  local s="${1// /_}"
  echo "${s^^}"
}

# plain → dot.case
string::plain_to_dot() {
  local s="${1// /.}"
  echo "${s,,}"
}

# plain → path/case
string::plain_to_path() {
  local s="${1// //}"
  echo "${s,,}"
}

# snake_case → plain
string::snake_to_plain() {
  echo "${1//_/ }"
}

# snake_case → kebab-case
string::snake_to_kebab() {
  echo "${1//_/-}"
}

# snake_case → camelCase
string::snake_to_camel() {
  string::plain_to_camel "${1//_/ }"
}

# snake_case → PascalCase
string::snake_to_pascal() {
  string::plain_to_pascal "${1//_/ }"
}

# snake_case → CONSTANT_CASE
string::snake_to_constant() {
  echo "${1^^}"
}

# snake_case → dot.case
string::snake_to_dot() {
  echo "${1//_/.}"
}

# snake_case → path/case
string::snake_to_path() {
  echo "${1//_//}"
}

# kebab-case → plain
string::kebab_to_plain() {
  echo "${1//-/ }"
}

# kebab-case → snake_case
string::kebab_to_snake() {
  echo "${1//-/_}"
}

# kebab-case → camelCase
string::kebab_to_camel() {
  string::plain_to_camel "${1//-/ }"
}

# kebab-case → PascalCase
string::kebab_to_pascal() {
  string::plain_to_pascal "${1//-/ }"
}

# kebab-case → CONSTANT_CASE
string::kebab_to_constant() {
  local s="${1//-/_}"
  echo "${s^^}"
}

# kebab-case → dot.case
string::kebab_to_dot() {
  echo "${1//-/.}"
}

# kebab-case → path/case
string::kebab_to_path() {
  echo "${1//-//}"
}

# camelCase → plain
string::camel_to_plain() {
  _string::to_words "$1"
}

# camelCase → snake_case
string::camel_to_snake() {
  local words
  words=$(_string::to_words "$1")
  echo "${words// /_}"
}

# camelCase → kebab-case
string::camel_to_kebab() {
  local words
  words=$(_string::to_words "$1")
  echo "${words// /-}"
}

# camelCase → PascalCase
string::camel_to_pascal() {
  string::plain_to_pascal "$(_string::to_words "$1")"
}

# camelCase → CONSTANT_CASE
string::camel_to_constant() {
  local words
  words=$(_string::to_words "$1")
  local s="${words// /_}"
  echo "${s^^}"
}

# camelCase → dot.case
string::camel_to_dot() {
  local words
  words=$(_string::to_words "$1")
  echo "${words// /.}"
}

# camelCase → path/case
string::camel_to_path() {
  local words
  words=$(_string::to_words "$1")
  echo "${words// //}"
}

# PascalCase → plain
string::pascal_to_plain() {
  _string::to_words "$1"
}

# PascalCase → snake_case
string::pascal_to_snake() {
  string::camel_to_snake "$1"
}

# PascalCase → kebab-case
string::pascal_to_kebab() {
  string::camel_to_kebab "$1"
}

# PascalCase → camelCase
string::pascal_to_camel() {
  local words
  words=$(_string::to_words "$1")
  string::plain_to_camel "$words"
}

# PascalCase → CONSTANT_CASE
string::pascal_to_constant() {
  string::camel_to_constant "$1"
}

# PascalCase → dot.case
string::pascal_to_dot() {
  string::camel_to_dot "$1"
}

# PascalCase → path/case
string::pascal_to_path() {
  string::camel_to_path "$1"
}

# CONSTANT_CASE → plain
string::constant_to_plain() {
  local s="${1//_/ }"
  echo "${s,,}"
}

# CONSTANT_CASE → snake_case
string::constant_to_snake() {
  echo "${1,,}"
}

# CONSTANT_CASE → kebab-case
string::constant_to_kebab() {
  local s="${1//_/-}"
  echo "${s,,}"
}

# CONSTANT_CASE → camelCase
string::constant_to_camel() {
  string::snake_to_camel "${1,,}"
}

# CONSTANT_CASE → PascalCase
string::constant_to_pascal() {
  string::snake_to_pascal "${1,,}"
}

# CONSTANT_CASE → dot.case
string::constant_to_dot() {
  local s="${1//_/.}"
  echo "${s,,}"
}

# CONSTANT_CASE → path/case
string::constant_to_path() {
  local s="${1//_//}"
  echo "${s,,}"
}

# dot.case → plain
string::dot_to_plain() {
  echo "${1//./ }"
}

# dot.case → snake_case
string::dot_to_snake() {
  echo "${1//./_}"
}

# dot.case → kebab-case
string::dot_to_kebab() {
  echo "${1//./-}"
}

# dot.case → camelCase
string::dot_to_camel() {
  string::plain_to_camel "${1//./ }"
}

# dot.case → PascalCase
string::dot_to_pascal() {
  string::plain_to_pascal "${1//./ }"
}

# dot.case → CONSTANT_CASE
string::dot_to_constant() {
  local s="${1//./_}"
  echo "${s^^}"
}

# dot.case → path/case
string::dot_to_path() {
  echo "${1//.//}"
}

# path/case → plain
string::path_to_plain() {
  echo "${1//\// }"
}

# path/case → snake_case
string::path_to_snake() {
  echo "${1//\//_}"
}

# path/case → kebab-case
string::path_to_kebab() {
  local path="$1"
  path="${path//\\/-}"  # Replace backslashes
  path="${path//\//-}"  # Replace forward slashes
  echo "$path"
}

# path/case → camelCase
string::path_to_camel() {
  string::plain_to_camel "${1//\// }"
}

# path/case → PascalCase
string::path_to_pascal() {
  string::plain_to_pascal "${1//\// }"
}

# path/case → CONSTANT_CASE
string::path_to_constant() {
  local s="${1//\//_}"
  echo "${s^^}"
}

# path/case → dot.case
string::path_to_dot() {
  echo "${1//\//.}"
}

# ==============================================================================
# TRIMMING
# ==============================================================================

# Trim leading whitespace
string::trim_left() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  echo "$s"
}

# Trim trailing whitespace
string::trim_right() {
  local s="$1"
  s="${s%"${s##*[![:space:]]}"}"
  echo "$s"
}

# Trim both leading and trailing whitespace
string::trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  echo "$s"
}

# Collapse multiple consecutive spaces into one
string::collapse_spaces() {
  echo "$1" | tr -s ' '
}

# Remove all whitespace
string::strip_spaces() {
  echo "${1//[[:space:]]/}"
}

# ==============================================================================
# SUBSTRINGS
# ==============================================================================

# Extract substring
# Usage: string::substr str start [length]
string::substr() {
  local s="$1" start="$2" len="${3:-}"
  if [[ -n "$len" ]]; then
    echo "${s:$start:$len}"
  else
    echo "${s:$start}"
  fi
}

# Index of first occurrence of substring (-1 if not found)
# Usage: string::index_of haystack needle
string::index_of() {
  local haystack="$1" needle="$2"
  local before="${haystack%%"$needle"*}"
  if [[ "$before" == "$haystack" ]]; then
    echo -1
  else
    echo "${#before}"
  fi
}

# Return everything before the first occurrence of delimiter
# Usage: string::before str delimiter
string::before() {
  echo "${1%%"$2"*}"
}

# Return everything after the first occurrence of delimiter
# Usage: string::after str delimiter
string::after() {
  echo "${1#*"$2"}"
}

# Return everything before the last occurrence of delimiter
string::before_last() {
  echo "${1%"$2"*}"
}

# Return everything after the last occurrence of delimiter
string::after_last() {
  echo "${1##*"$2"}"
}

# ==============================================================================
# MANIPULATION
# ==============================================================================

# Replace first occurrence of search with replace
# Usage: string::replace str search replace
string::replace() {
  echo "${1/"$2"/"$3"}"
}

# Replace all occurrences of search with replace
string::replace_all() {
  echo "${1//"$2"/"$3"}"
}

# Remove all occurrences of a substring
string::remove() {
  echo "${1//"$2"/}"
}

# Remove first occurrence of a substring
string::remove_first() {
  echo "${1/"$2"/}"
}

# Reverse a string
# Requires: rev (coreutils) — falls back to awk
string::reverse() {
  if runtime::has_command rev; then
    echo "$1" | rev
  else
    echo "$1" | awk '{for(i=length;i>0;i--) printf substr($0,i,1); print ""}'
  fi
}

# Repeat a string n times
# Usage: string::repeat str n
string::repeat() {
  local str="$1" n="$2" result=""
  for ((i = 0; i < n; i++)); do result+="$str"; done
  echo "$result"
}

# Pad string on the left to a given width
# Usage: string::pad_left str width [char]
string::pad_left() {
  local s="$1" width="$2" char="${3:- }"
  local len="${#s}"
  if ((len >= width)); then
    echo "$s"
    return
  fi
  local pad
  pad=$(string::repeat "$char" $((width - len)))
  echo "${pad}${s}"
}

# Pad string on the right to a given width
# Usage: string::pad_right str width [char]
string::pad_right() {
  local s="$1" width="$2" char="${3:- }"
  local len="${#s}"
  if ((len >= width)); then
    echo "$s"
    return
  fi
  local pad
  pad=$(string::repeat "$char" $((width - len)))
  echo "${s}${pad}"
}

# Centre a string within a given width
# Usage: string::pad_center str width [char]
string::pad_center() {
  local s="$1" width="$2" char="${3:- }"
  local len="${#s}"
  if ((len >= width)); then
    echo "$s"
    return
  fi
  local total=$((width - len))
  local left=$((total / 2))
  local right=$((total - left))
  local lpad rpad
  lpad=$(string::repeat "$char" $left)
  rpad=$(string::repeat "$char" $right)
  echo "${lpad}${s}${rpad}"
}

# Truncate a string to max length, appending suffix if truncated
# Usage: string::truncate str max [suffix]
string::truncate() {
  local s="$1" max="$2"
  local suffix

  if ((${#s} <= max)); then
    echo "$s"
    return 0
  fi

  # Handle very small max values
  if ((max <= 1)); then
    # Can only show suffix
    echo "…"
    return 0
  elif ((max == 2)); then
    # Can show 1 char + single ellipsis
    echo "${s:0:1}…"
    return 0
  fi

  # Determine which suffix to use based on available space
  local available_chars=$((max - 3))  # Try with 3-dot suffix first

  if ((available_chars < 3)); then
    # If we'd have less than 3 chars from original with 3-dot suffix,
    # use single ellipsis instead
    suffix="…"
    available_chars=$((max - 1))
  else
    suffix="..."
  fi

  echo "${s:0:$available_chars}${suffix}"
}

# ==============================================================================
# SPLITTING / JOINING
# ==============================================================================

# Split a string by delimiter into lines (one element per line)
# Usage: string::split str delimiter
string::split() {
  local s="$1" delim="$2"
  local IFS="$delim"
  # Remove IFS from positional parameters to enable word splitting
  set -- $s
  printf '%s\n' "$@"
}


# Join an array of arguments with a delimiter
# Usage: string::join delimiter arg1 arg2 ...
string::join() {
  local delim="$1"
  shift
  local result=""
  local first=true
  for part in "$@"; do
    if $first; then
      result="$part"
      first=false
    else
      result+="${delim}${part}"
    fi
  done
  echo "$result"
}

# ==============================================================================
# ENCODING / HASHING
# ==============================================================================

# URL-encode a string
string::url_encode() {
    local s="$1" encoded="" i char hex
    for (( i=0; i<${#s}; i++ )); do
        char="${s:$i:1}"
        case "$char" in
            [a-zA-Z0-9.~_-]) encoded+="$char" ;;
            *) printf -v hex '%02X' "'$char"
               encoded+="%$hex" ;;
        esac
    done
    echo "$encoded"
}

string::url_decode() {
    local s="${1//+/ }"  # replace + with space first
    printf '%b\n' "${s//%/\\x}"
}

# Base64 encode
string::base64_encode() {
    case "$(runtime::os)" in
    darwin) echo -n "$1" | base64 ;;
    *)      echo -n "$1" | base64 -w 0 ;;
    esac
}

# Base64 decode
string::base64_decode() {
    case "$(runtime::os)" in
    darwin) echo -n "$1" | base64 -D ;;
    *)      echo -n "$1" | base64 --decode ;;
    esac
}

string::base64_encode::pure() {
    local s="$1" out="" i a b c
    local _B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    for (( i=0; i<${#s}; i+=3 )); do
        a=$(printf '%d' "'${s:$i:1}")
        b=$(( i+1 < ${#s} ? $(printf '%d' "'${s:$((i+1)):1}") : 0 ))
        c=$(( i+2 < ${#s} ? $(printf '%d' "'${s:$((i+2)):1}") : 0 ))

        out+="${_B64:$(( (a >> 2) & 63 )):1}"
        out+="${_B64:$(( ((a << 4) | (b >> 4)) & 63 )):1}"
        out+="${_B64:$(( i+1 < ${#s} ? ((b << 2) | (c >> 6)) & 63 : 64 )):1}"
        out+="${_B64:$(( i+2 < ${#s} ? c & 63 : 64 )):1}"
    done

    echo "$out"
}

string::base64_decode::pure() {
    local s="$1" i
    local -i a b c d byte1 byte2 byte3
    local _B64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    # strip padding
    s="${s//=}"

    for (( i=0; i<${#s}; i+=4 )); do
        local c0="${s:$i:1}" c1="${s:$((i+1)):1}" c2="${s:$((i+2)):1}" c3="${s:$((i+3)):1}"
        # Use case for reliable index lookup (avoids issues with +/ in patterns)
        case "$c0" in A) a=0;; B) a=1;; C) a=2;; D) a=3;; E) a=4;; F) a=5;; G) a=6;; H) a=7;; I) a=8;; J) a=9;; K) a=10;; L) a=11;; M) a=12;; N) a=13;; O) a=14;; P) a=15;; Q) a=16;; R) a=17;; S) a=18;; T) a=19;; U) a=20;; V) a=21;; W) a=22;; X) a=23;; Y) a=24;; Z) a=25;; a) a=26;; b) a=27;; c) a=28;; d) a=29;; e) a=30;; f) a=31;; g) a=32;; h) a=33;; i) a=34;; j) a=35;; k) a=36;; l) a=37;; m) a=38;; n) a=39;; o) a=40;; p) a=41;; q) a=42;; r) a=43;; s) a=44;; t) a=45;; u) a=46;; v) a=47;; w) a=48;; x) a=49;; y) a=50;; z) a=51;; 0) a=52;; 1) a=53;; 2) a=54;; 3) a=55;; 4) a=56;; 5) a=57;; 6) a=58;; 7) a=59;; 8) a=60;; 9) a=61;; +) a=62;; /) a=63;; *) a=0;; esac
        case "$c1" in A) b=0;; B) b=1;; C) b=2;; D) b=3;; E) b=4;; F) b=5;; G) b=6;; H) b=7;; I) b=8;; J) b=9;; K) b=10;; L) b=11;; M) b=12;; N) b=13;; O) b=14;; P) b=15;; Q) b=16;; R) b=17;; S) b=18;; T) b=19;; U) b=20;; V) b=21;; W) b=22;; X) b=23;; Y) b=24;; Z) b=25;; a) b=26;; b) b=27;; c) b=28;; d) b=29;; e) b=30;; f) b=31;; g) b=32;; h) b=33;; i) b=34;; j) b=35;; k) b=36;; l) b=37;; m) b=38;; n) b=39;; o) b=40;; p) b=41;; q) b=42;; r) b=43;; s) b=44;; t) b=45;; u) b=46;; v) b=47;; w) b=48;; x) b=49;; y) b=50;; z) b=51;; 0) b=52;; 1) b=53;; 2) b=54;; 3) b=55;; 4) b=56;; 5) b=57;; 6) b=58;; 7) b=59;; 8) b=60;; 9) b=61;; +) b=62;; /) b=63;; *) b=0;; esac
        case "$c2" in A) c=0;; B) c=1;; C) c=2;; D) c=3;; E) c=4;; F) c=5;; G) c=6;; H) c=7;; I) c=8;; J) c=9;; K) c=10;; L) c=11;; M) c=12;; N) c=13;; O) c=14;; P) c=15;; Q) c=16;; R) c=17;; S) c=18;; T) c=19;; U) c=20;; V) c=21;; W) c=22;; X) c=23;; Y) c=24;; Z) c=25;; a) c=26;; b) c=27;; c) c=28;; d) c=29;; e) c=30;; f) c=31;; g) c=32;; h) c=33;; i) c=34;; j) c=35;; k) c=36;; l) c=37;; m) c=38;; n) c=39;; o) c=40;; p) c=41;; q) c=42;; r) c=43;; s) c=44;; t) c=45;; u) c=46;; v) c=47;; w) c=48;; x) c=49;; y) c=50;; z) c=51;; 0) c=52;; 1) c=53;; 2) c=54;; 3) c=55;; 4) c=56;; 5) c=57;; 6) c=58;; 7) c=59;; 8) c=60;; 9) c=61;; +) c=62;; /) c=63;; *) c=0;; esac
        case "$c3" in A) d=0;; B) d=1;; C) d=2;; D) d=3;; E) d=4;; F) d=5;; G) d=6;; H) d=7;; I) d=8;; J) d=9;; K) d=10;; L) d=11;; M) d=12;; N) d=13;; O) d=14;; P) d=15;; Q) d=16;; R) d=17;; S) d=18;; T) d=19;; U) d=20;; V) d=21;; W) d=22;; X) d=23;; Y) d=24;; Z) d=25;; a) d=26;; b) d=27;; c) d=28;; d) d=29;; e) d=30;; f) d=31;; g) d=32;; h) d=33;; i) d=34;; j) d=35;; k) d=36;; l) d=37;; m) d=38;; n) d=39;; o) d=40;; p) d=41;; q) d=42;; r) d=43;; s) d=44;; t) d=45;; u) d=46;; v) d=47;; w) d=48;; x) d=49;; y) d=50;; z) d=51;; 0) d=52;; 1) d=53;; 2) d=54;; 3) d=55;; 4) d=56;; 5) d=57;; 6) d=58;; 7) d=59;; 8) d=60;; 9) d=61;; +) d=62;; /) d=63;; *) d=0;; esac

        byte1=$(( (a << 2) | (b >> 4) ))
        byte2=$(( ((b & 15) << 4) | (c >> 2) ))
        byte3=$(( ((c & 3) << 6) | d ))

        printf "\\$(printf '%03o' $byte1)"
        (( i+2 < ${#s} )) && printf "\\$(printf '%03o' $byte2)"
        (( i+3 < ${#s}  )) && printf "\\$(printf '%03o' $byte3)"
    done
    echo
}

string::base32_encode() {
    if runtime::has_command base32; then
        echo -n "$1" | base32
    elif runtime::has_command gbase32; then  # homebrew coreutils on macOS
        echo -n "$1" | gbase32
    else
        echo "string::base32_encode: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}

string::base32_decode() {
    if runtime::has_command base32; then
        echo -n "$1" | base32 --decode
    elif runtime::has_command gbase32; then
        echo -n "$1" | gbase32 --decode
    else
        echo "string::base32_decode: requires base32 (GNU coreutils)" >&2
        return 1
    fi
}

string::base32_encode::pure() {
    local _B32="ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    local s="$1" out="" i a b c d e

    for (( i=0; i<${#s}; i+=5 )); do
        a=$(printf '%d' "'${s:$i:1}")
        b=$(( i+1 < ${#s} ? $(printf '%d' "'${s:$((i+1)):1}") : 0 ))
        c=$(( i+2 < ${#s} ? $(printf '%d' "'${s:$((i+2)):1}") : 0 ))
        d=$(( i+3 < ${#s} ? $(printf '%d' "'${s:$((i+3)):1}") : 0 ))
        e=$(( i+4 < ${#s} ? $(printf '%d' "'${s:$((i+4)):1}") : 0 ))

        out+="${_B32:$(( (a >> 3) & 31 )):1}"
        out+="${_B32:$(( ((a << 2) | (b >> 6)) & 31 )):1}"
        out+="${_B32:$(( i+1 < ${#s} ? (b >> 1) & 31 : 32 )):1}"
        out+="${_B32:$(( i+1 < ${#s} ? ((b << 4) | (c >> 4)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+2 < ${#s} ? ((c << 1) | (d >> 7)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+3 < ${#s} ? (d >> 2) & 31 : 32 )):1}"
        out+="${_B32:$(( i+3 < ${#s} ? ((d << 3) | (e >> 5)) & 31 : 32 )):1}"
        out+="${_B32:$(( i+4 < ${#s} ? e & 31 : 32 )):1}"
    done

    echo "$out"
}

string::base32_decode::pure() {
    local s="${1//=}" i
    local -i a b c d e f g h

    # uppercase input since base32 alphabet is uppercase only
    s="${s^^}"

    for (( i=0; i<${#s}; i+=8 )); do
        local c0="${s:$i:1}" c1="${s:$((i+1)):1}" c2="${s:$((i+2)):1}" c3="${s:$((i+3)):1}"
        local c4="${s:$((i+4)):1}" c5="${s:$((i+5)):1}" c6="${s:$((i+6)):1}" c7="${s:$((i+7)):1}"
        # Use case for reliable index lookup (base32 alphabet: A-Z, 2-7)
        case "$c0" in A) a=0;; B) a=1;; C) a=2;; D) a=3;; E) a=4;; F) a=5;; G) a=6;; H) a=7;; I) a=8;; J) a=9;; K) a=10;; L) a=11;; M) a=12;; N) a=13;; O) a=14;; P) a=15;; Q) a=16;; R) a=17;; S) a=18;; T) a=19;; U) a=20;; V) a=21;; W) a=22;; X) a=23;; Y) a=24;; Z) a=25;; 2) a=26;; 3) a=27;; 4) a=28;; 5) a=29;; 6) a=30;; 7) a=31;; *) a=0;; esac
        case "$c1" in A) b=0;; B) b=1;; C) b=2;; D) b=3;; E) b=4;; F) b=5;; G) b=6;; H) b=7;; I) b=8;; J) b=9;; K) b=10;; L) b=11;; M) b=12;; N) b=13;; O) b=14;; P) b=15;; Q) b=16;; R) b=17;; S) b=18;; T) b=19;; U) b=20;; V) b=21;; W) b=22;; X) b=23;; Y) b=24;; Z) b=25;; 2) b=26;; 3) b=27;; 4) b=28;; 5) b=29;; 6) b=30;; 7) b=31;; *) b=0;; esac
        case "$c2" in A) c=0;; B) c=1;; C) c=2;; D) c=3;; E) c=4;; F) c=5;; G) c=6;; H) c=7;; I) c=8;; J) c=9;; K) c=10;; L) c=11;; M) c=12;; N) c=13;; O) c=14;; P) c=15;; Q) c=16;; R) c=17;; S) c=18;; T) c=19;; U) c=20;; V) c=21;; W) c=22;; X) c=23;; Y) c=24;; Z) c=25;; 2) c=26;; 3) c=27;; 4) c=28;; 5) c=29;; 6) c=30;; 7) c=31;; *) c=0;; esac
        case "$c3" in A) d=0;; B) d=1;; C) d=2;; D) d=3;; E) d=4;; F) d=5;; G) d=6;; H) d=7;; I) d=8;; J) d=9;; K) d=10;; L) d=11;; M) d=12;; N) d=13;; O) d=14;; P) d=15;; Q) d=16;; R) d=17;; S) d=18;; T) d=19;; U) d=20;; V) d=21;; W) d=22;; X) d=23;; Y) d=24;; Z) d=25;; 2) d=26;; 3) d=27;; 4) d=28;; 5) d=29;; 6) d=30;; 7) d=31;; *) d=0;; esac
        case "$c4" in A) e=0;; B) e=1;; C) e=2;; D) e=3;; E) e=4;; F) e=5;; G) e=6;; H) e=7;; I) e=8;; J) e=9;; K) e=10;; L) e=11;; M) e=12;; N) e=13;; O) e=14;; P) e=15;; Q) e=16;; R) e=17;; S) e=18;; T) e=19;; U) e=20;; V) e=21;; W) e=22;; X) e=23;; Y) e=24;; Z) e=25;; 2) e=26;; 3) e=27;; 4) e=28;; 5) e=29;; 6) e=30;; 7) e=31;; *) e=0;; esac
        case "$c5" in A) f=0;; B) f=1;; C) f=2;; D) f=3;; E) f=4;; F) f=5;; G) f=6;; H) f=7;; I) f=8;; J) f=9;; K) f=10;; L) f=11;; M) f=12;; N) f=13;; O) f=14;; P) f=15;; Q) f=16;; R) f=17;; S) f=18;; T) f=19;; U) f=20;; V) f=21;; W) f=22;; X) f=23;; Y) f=24;; Z) f=25;; 2) f=26;; 3) f=27;; 4) f=28;; 5) f=29;; 6) f=30;; 7) f=31;; *) f=0;; esac
        case "$c6" in A) g=0;; B) g=1;; C) g=2;; D) g=3;; E) g=4;; F) g=5;; G) g=6;; H) g=7;; I) g=8;; J) g=9;; K) g=10;; L) g=11;; M) g=12;; N) g=13;; O) g=14;; P) g=15;; Q) g=16;; R) g=17;; S) g=18;; T) g=19;; U) g=20;; V) g=21;; W) g=22;; X) g=23;; Y) g=24;; Z) g=25;; 2) g=26;; 3) g=27;; 4) g=28;; 5) g=29;; 6) g=30;; 7) g=31;; *) g=0;; esac
        case "$c7" in A) h=0;; B) h=1;; C) h=2;; D) h=3;; E) h=4;; F) h=5;; G) h=6;; H) h=7;; I) h=8;; J) h=9;; K) h=10;; L) h=11;; M) h=12;; N) h=13;; O) h=14;; P) h=15;; Q) h=16;; R) h=17;; S) h=18;; T) h=19;; U) h=20;; V) h=21;; W) h=22;; X) h=23;; Y) h=24;; Z) h=25;; 2) h=26;; 3) h=27;; 4) h=28;; 5) h=29;; 6) h=30;; 7) h=31;; *) h=0;; esac

        printf "\\$(printf '%03o' $(( (a << 3) | (b >> 2) )))"
        (( i+2 < ${#s} )) && printf "\\$(printf '%03o' $(( ((b & 3) << 6) | (c << 1) | (d >> 4) )))"
        (( i+4 < ${#s} )) && printf "\\$(printf '%03o' $(( ((d & 15) << 4) | (e >> 1) )))"
        (( i+5 < ${#s} )) && printf "\\$(printf '%03o' $(( ((e & 1) << 7) | (f << 2) | (g >> 3) )))"
        (( i+7 < ${#s} )) && printf "\\$(printf '%03o' $(( ((g & 7) << 5) | h )))"
    done
    echo
}

# MD5 hash of a string
# Requires: md5sum (Linux) or md5 (macOS)
string::md5() {
  if command -v md5sum >/dev/null 2>&1; then
    echo -n "$1" | md5sum | cut -d' ' -f1
  elif command -v md5 >/dev/null 2>&1; then
    echo -n "$1" | md5
  else
    echo "string::md5: requires md5sum or md5" >&2
    return 1
  fi
}

# SHA256 hash of a string
# Requires: sha256sum (Linux) or shasum (macOS)
string::sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    echo -n "$1" | sha256sum | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    echo -n "$1" | shasum -a 256 | cut -d' ' -f1
  else
    echo "string::sha256: requires sha256sum or shasum" >&2
    return 1
  fi
}

# ==============================================================================
# GENERATION
# ==============================================================================

# Generate a random alphanumeric string of given length
# Usage: string::random [length]
string::random() {
  local len="${1:-16}"
  cat /dev/urandom 2>/dev/null |
    tr -dc 'a-zA-Z0-9' |
    head -c "$len" ||
    echo "string::random: /dev/urandom unavailable" >&2
}

# Generate a UUID v4 (random)
string::uuid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr '[:upper:]' '[:lower:]'
  elif [[ -f /proc/sys/kernel/random/uuid ]]; then
    cat /proc/sys/kernel/random/uuid
  else
    # Manual construction from /dev/urandom
    local b
    b=$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
    printf '%s-%s-4%s-%s%s-%s\n' \
      "${b:0:8}" "${b:8:4}" "${b:13:3}" \
      "$(((16#${b:16:1} & 3) | 8))${b:17:3}" \
      "${b:20:4}" "${b:24:12}"
  fi
}

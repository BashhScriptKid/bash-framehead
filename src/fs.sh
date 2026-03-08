#!/usr/bin/env bash
# fs.sh — bash-frameheader filesystem lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# PATH MANIPULATION
# Pure string operations — no filesystem access required
# ==============================================================================

# Join path components
# Usage: fs::path::join part1 part2 ...
fs::path::join() {
    local result="$1"; shift
    for part in "$@"; do
        part="${part#/}"   # strip leading slash from each part
        result="${result%/}/$part"
    done
    echo "$result"
}

# Get filename from path (like basename)
fs::path::basename() {
    echo "${1##*/}"
}

# Get directory from path (like dirname)
fs::path::dirname() {
    local p="${1%/*}"
    [[ "$p" == "$1" ]] && echo "." || echo "$p"
}

# Get file extension (without dot)
# Usage: fs::path::extension file.tar.gz → gz
fs::path::extension() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base##*.}" || echo ""
}

# Get all extensions for multi-part extensions
# Usage: fs::path::extensions file.tar.gz → tar.gz
fs::path::extensions() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base#*.}" || echo ""
}

# Strip extension from filename
fs::path::stem() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base%.*}" || echo "$base"
}

# Get absolute path (resolves . and .. without requiring the path to exist)
fs::path::absolute() {
    local p="$1"
    if [[ "$p" != /* ]]; then
        p="$(pwd)/$p"
    fi
    # Resolve . and .. manually
    local -a parts=() result=()
    IFS='/' read -ra parts <<< "$p"
    for part in "${parts[@]}"; do
        case "$part" in
            ""|.) ;;
            ..)   [[ ${#result[@]} -gt 0 ]] && unset 'result[-1]' ;;
            *)    result+=("$part") ;;
        esac
    done
    echo "/${result[*]// //}"
}

# Get path relative to a base
# Usage: fs::path::relative /a/b/c /a → b/c
fs::path::relative() {
    local target="$1" base="$2"
    # Strip common prefix
    while [[ "$target" == "$base"* && "$base" != "/" ]]; do
        target="${target#$base}"
        target="${target#/}"
        break
    done
    echo "$target"
}

# Check if a path is absolute
fs::path::is_absolute() {
    [[ "$1" == /* ]]
}

# Check if a path is relative
fs::path::is_relative() {
    [[ "$1" != /* ]]
}

# ==============================================================================
# FILE / DIR CHECKS
# ==============================================================================

fs::exists()        { [[ -e "$1" ]]; }
fs::is_file()       { [[ -f "$1" ]]; }
fs::is_dir()        { [[ -d "$1" ]]; }
fs::is_symlink()    { [[ -L "$1" ]]; }
fs::is_readable()   { [[ -r "$1" ]]; }
fs::is_writable()   { [[ -w "$1" ]]; }
fs::is_executable() { [[ -x "$1" ]]; }
fs::is_empty()      { [[ -f "$1" && ! -s "$1" ]] || [[ -d "$1" && -z "$(ls -A "$1" 2>/dev/null)" ]]; }

# Check if two paths resolve to the same file (inode comparison)
fs::is_same() {
    [[ "$(stat -c '%d:%i' "$1" 2>/dev/null)" == "$(stat -c '%d:%i' "$2" 2>/dev/null)" ]]
}

# ==============================================================================
# FILE INFO
# ==============================================================================

# File size in bytes
fs::size() {
    stat -c '%s' "$1" 2>/dev/null || wc -c < "$1" 2>/dev/null
}

# Human-readable file size
fs::size::human() {
    local size
    size=$(fs::size "$1")
    if runtime::has_command numfmt; then
        numfmt --to=iec-i --suffix=B "$size"
    else
        awk -v s="$size" 'BEGIN {
            split("B KiB MiB GiB TiB", u)
            i=1; while(s>=1024 && i<5){s/=1024; i++}
            printf "%.1f%s\n", s, u[i]
        }'
    fi
}

# Last modified time (unix timestamp)
fs::modified() {
    stat -c '%Y' "$1" 2>/dev/null
}

# Last modified time (human readable)
fs::modified::human() {
    stat -c '%y' "$1" 2>/dev/null
}

# Creation time (unix timestamp) — not available on all filesystems
fs::created() {
    stat -c '%W' "$1" 2>/dev/null
}

# Octal permissions
fs::permissions() {
    stat -c '%a' "$1" 2>/dev/null
}

# Symbolic permissions (e.g. -rwxr-xr-x)
fs::permissions::symbolic() {
    stat -c '%A' "$1" 2>/dev/null
}

# Owner username
fs::owner() {
    stat -c '%U' "$1" 2>/dev/null
}

# Owner group
fs::owner::group() {
    stat -c '%G' "$1" 2>/dev/null
}

# Inode number
fs::inode() {
    stat -c '%i' "$1" 2>/dev/null
}

# MIME type
fs::mime_type() {
    if runtime::has_command file; then
        file --mime-type -b "$1" 2>/dev/null
    else
        echo "unknown"
    fi
}

# Number of hard links
fs::link_count() {
    stat -c '%h' "$1" 2>/dev/null
}

# Symlink target
fs::symlink::target() {
    readlink "$1" 2>/dev/null
}

# Resolved symlink target (follows chain)
fs::symlink::resolve() {
    readlink -f "$1" 2>/dev/null
}

# ==============================================================================
# OPERATIONS
# ==============================================================================

# Copy file or directory
# Usage: fs::copy src dst
fs::copy() {
    cp -r "$1" "$2"
}

# Move/rename
fs::move() {
    mv "$1" "$2"
}

# Delete file or directory
fs::delete() {
    rm -rf "$1"
}

# Create directory (including parents)
fs::mkdir() {
    mkdir -p "$1"
}

# Touch a file (create or update timestamp)
fs::touch() {
    touch "$1"
}

# Create a symlink
# Usage: fs::symlink target link_name
fs::symlink() {
    ln -s "$1" "$2"
}

# Create a hard link
fs::hardlink() {
    ln "$1" "$2"
}

# Rename just the filename, keeping directory
# Usage: fs::rename old_path new_name
fs::rename() {
    local dir
    dir="$(fs::path::dirname "$1")"
    mv "$1" "$dir/$2"
}

# Safely delete to a trash dir instead of permanent delete
# Usage: fs::trash path
fs::trash() {
    local trash_dir="${HOME}/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    mv "$1" "$trash_dir/$(fs::path::basename "$1").$(date +%s)"
}

# ==============================================================================
# TEMP FILES
# ==============================================================================

# Create a temporary file, print its path
# Usage: tmpfile=$(fs::temp::file [prefix])
fs::temp::file() {
    local prefix="${1:-fsbshf}"
    mktemp "/tmp/${prefix}.XXXXXX"
}

# Create a temporary directory, print its path
# Usage: tmpdir=$(fs::temp::dir [prefix])
fs::temp::dir() {
    local prefix="${1:-fsbshf}"
    mktemp -d "/tmp/${prefix}.XXXXXX"
}

# Create a temp file and register cleanup on EXIT
# Usage: fs::temp::file::auto [prefix]
fs::temp::file::auto() {
    local tmp
    tmp=$(fs::temp::file "$1")
    trap "rm -f '$tmp'" EXIT
    echo "$tmp"
}

# Create a temp dir and register cleanup on EXIT
fs::temp::dir::auto() {
    local tmp
    tmp=$(fs::temp::dir "$1")
    trap "rm -rf '$tmp'" EXIT
    echo "$tmp"
}

# ==============================================================================
# READING / WRITING
# ==============================================================================

# Read entire file contents
fs::read() {
    cat "$1"
}

# Write content to file (overwrites)
# Usage: fs::write path content
fs::write() {
    printf '%s' "$2" > "$1"
}

# Write with newline
fs::writeln() {
    printf '%s\n' "$2" > "$1"
}

# Append content to file
fs::append() {
    printf '%s' "$2" >> "$1"
}

# Append with newline
fs::appendln() {
    printf '%s\n' "$2" >> "$1"
}

# Read a specific line number (1-indexed)
# Usage: fs::line path line_number
fs::line() {
    sed -n "${2}p" "$1"
}

# Read a range of lines
# Usage: fs::lines path start end
fs::lines() {
    sed -n "${2},${3}p" "$1"
}

# Count lines in a file
fs::line_count() {
    wc -l < "$1"
}

# Count words in a file
fs::word_count() {
    wc -w < "$1"
}

# Count characters in a file
fs::char_count() {
    wc -c < "$1"
}

# Check if file contains a string
# Usage: fs::contains path string
fs::contains() {
    grep -qF "$2" "$1" 2>/dev/null
}

# Check if file matches a regex
fs::matches() {
    grep -qE "$2" "$1" 2>/dev/null
}

# Replace string in file (in-place)
# Usage: fs::replace path old new
fs::replace() {
    sed -i "s|${2}|${3}|g" "$1"
}

# Prepend content to file
fs::prepend() {
    local tmp
    tmp=$(fs::temp::file)
    printf '%s\n' "$2" | cat - "$1" > "$tmp"
    mv "$tmp" "$1"
}

# ==============================================================================
# DIRECTORY OPERATIONS
# ==============================================================================

# List directory contents (one per line)
fs::ls() {
    ls -1 "${1:-.}"
}

# List with hidden files
fs::ls::all() {
    ls -1A "${1:-.}"
}

# List only files
fs::ls::files() {
    find "${1:-.}" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep -v '/$'
}

# List only directories
fs::ls::dirs() {
    find "${1:-.}" -maxdepth 1 -type d -not -path "${1:-.}" -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep '/$' | tr -d '/'
}

# Recursive find by name pattern
# Usage: fs::find path pattern
fs::find() {
    find "${1:-.}" -name "$2" 2>/dev/null
}

# Recursive find by type (f=file, d=dir, l=symlink)
fs::find::type() {
    find "${1:-.}" -type "$2" 2>/dev/null
}

# Find files modified within n minutes
fs::find::recent() {
    find "${1:-.}" -type f -mmin "-${2:-60}" 2>/dev/null
}

# Find files larger than n bytes
fs::find::larger_than() {
    find "${1:-.}" -type f -size "+${2}c" 2>/dev/null
}

# Find files smaller than n bytes
fs::find::smaller_than() {
    find "${1:-.}" -type f -size "-${2}c" 2>/dev/null
}

# Get total size of directory
fs::dir::size() {
    du -sb "${1:-.}" 2>/dev/null | awk '{print $1}'
}

# Get total size of directory, human readable
fs::dir::size::human() {
    du -sh "${1:-.}" 2>/dev/null | awk '{print $1}'
}

# Count items in directory
fs::dir::count() {
    find "${1:-.}" -maxdepth 1 -not -path "${1:-.}" 2>/dev/null | wc -l
}

# Check if directory is empty
fs::dir::is_empty() {
    [[ -z "$(ls -A "${1:-.}" 2>/dev/null)" ]]
}

# ==============================================================================
# WATCHING
# ==============================================================================

# Watch a file for changes, run callback on change
# Usage: fs::watch path callback [interval_seconds]
# Callback receives the path as $1
fs::watch() {
    local last_modified
    last_modified=$(fs::modified "$1")

    while true; do
        sleep "${3:-1}"
        local current
        current=$(fs::modified "$1")
        if [[ "$current" != "$last_modified" ]]; then
            last_modified="$current"
            "$2" "$1"
        fi
    done
}

# Watch with a timeout (seconds)
# Usage: fs::watch::timeout path callback timeout [interval]
fs::watch::timeout() {
    local elapsed=0
    local last_modified
    last_modified=$(fs::modified "$1")

    while (( elapsed < ${3:-} )); do
        sleep "${4:-1}"
        (( elapsed += ${4:-1} ))
        local current
        current=$(fs::modified "$1")
        if [[ "$current" != "$last_modified" ]]; then
            last_modified="$current"
            "$2" "$1"
        fi
    done
}

# ==============================================================================
# CHECKSUMS
# ==============================================================================

fs::checksum::md5() {
    if runtime::has_command md5sum; then
        md5sum "$1" | awk '{print $1}'
    elif runtime::has_command md5; then
        md5 -q "$1"
    fi
}

fs::checksum::sha1() {
    if runtime::has_command sha1sum; then
        sha1sum "$1" | awk '{print $1}'
    elif runtime::has_command shasum; then
        shasum -a 1 "$1" | awk '{print $1}'
    fi
}

fs::checksum::sha256() {
    if runtime::has_command sha256sum; then
        sha256sum "$1" | awk '{print $1}'
    elif runtime::has_command shasum; then
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

# Check if two files are identical (by content)
fs::is_identical() {
    local sum1 sum2
    sum1=$(fs::checksum::sha256 "$1")
    sum2=$(fs::checksum::sha256 "$2")
    [[ "$sum1" == "$sum2" ]]
}

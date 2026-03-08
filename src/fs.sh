#!/usr/bin/env bash
# fs.sh — bash-frameheader filesystem lib
# Requires: runtime.sh (runtime::has_command)

# ==============================================================================
# PATH MANIPULATION
# Pure string operations — no filesystem access required
# ==============================================================================

# Join multiple path components into a single well-formed path.
# Use this instead of string concatenation to avoid double slashes or missing
# separators when building paths from dynamic parts.
#
# Usage: fs::path::join part1 part2 ...
#   fs::path::join "/var/log" "app" "server.log"   # → /var/log/app/server.log
#
# Returns: echoes the joined path; returns 0
#
# Note: Leading slashes on parts after the first are stripped so that
# fs::path::join "/a" "/b" produces "/a/b" rather than "/a//b".
fs::path::join() {
    local result="$1"; shift
    for part in "$@"; do
        part="${part#/}"   # strip leading slash from each part
        result="${result%/}/$part"
    done
    echo "$result"
}

# Extract the filename from a path, stripping all leading directory components.
# Use this as a pure-string alternative to the basename command when you want
# to avoid a subshell or don't have basename available.
#
# Usage: fs::path::basename path
#   fs::path::basename "/var/log/app/server.log"   # → server.log
#
# Returns: echoes the filename portion of the path; returns 0
fs::path::basename() {
    echo "${1##*/}"
}

# Extract the directory portion of a path, stripping the trailing filename.
# Use this as a pure-string alternative to the dirname command when building
# parent paths or resolving sibling files.
#
# Usage: fs::path::dirname path
#   fs::path::dirname "/var/log/app/server.log"   # → /var/log/app
#   fs::path::dirname "server.log"                # → .
#
# Returns: echoes the directory portion; echoes "." if there is no directory component
fs::path::dirname() {
    local p="${1%/*}"
    [[ "$p" == "$1" ]] && echo "." || echo "$p"
}

# Extract the final extension from a filename, without the dot.
# Use this to branch on file type, build output filenames, or validate
# that a file has an expected format.
#
# Usage: fs::path::extension path
#   fs::path::extension "archive.tar.gz"   # → gz
#   fs::path::extension "README"           # → (empty string)
#
# Returns: echoes the extension without leading dot; echoes empty string if none
#
# Note: Only returns the last extension. For multi-part extensions like
# .tar.gz use fs::path::extensions instead.
fs::path::extension() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base##*.}" || echo ""
}

# Extract all extensions from a filename as a single dot-separated string.
# Use this when the full compound extension matters, such as distinguishing
# .tar.gz from .gz or routing multi-format files correctly.
#
# Usage: fs::path::extensions path
#   fs::path::extensions "archive.tar.gz"   # → tar.gz
#   fs::path::extensions "report.pdf"       # → pdf
#
# Returns: echoes everything after the first dot in the filename; echoes empty string if none
fs::path::extensions() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base#*.}" || echo ""
}

# Extract the filename without its final extension (the "stem").
# Use this when you need the base name of a file to construct a related
# output path, e.g. converting "report.pdf" into "report.html".
#
# Usage: fs::path::stem path
#   fs::path::stem "archive.tar.gz"   # → archive.tar
#   fs::path::stem "README"           # → README
#
# Returns: echoes the filename with the last extension removed; returns 0
#
# Note: Strips only the final extension. "archive.tar.gz" becomes "archive.tar",
# not "archive". Use in combination with fs::path::extensions if you need to
# strip the full compound extension.
fs::path::stem() {
    local base="${1##*/}"
    [[ "$base" == *.* ]] && echo "${base%.*}" || echo "$base"
}

# Resolve a path to its absolute form, collapsing . and .. components.
# Use this to normalise user-supplied or relative paths before storing,
# logging, or comparing them — without requiring the path to actually exist.
#
# Usage: fs::path::absolute path
#   fs::path::absolute "../../etc/hosts"   # → /etc/hosts (from cwd)
#   fs::path::absolute "/var/log/../app"   # → /var/app
#
# Returns: echoes the resolved absolute path; returns 0
#
# Note: Does not access the filesystem, so it works on paths that don't exist yet.
# For paths that do exist and may involve symlinks, use fs::symlink::resolve instead.
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

# Strip a base prefix from a path to produce a relative path.
# Use this when displaying or storing paths that should be relative to a
# known root, such as project files relative to a workspace directory.
#
# Usage: fs::path::relative target base
#   fs::path::relative "/a/b/c" "/a"   # → b/c
#
# Returns: echoes the relative path; returns 0
#
# Note: This is a simple prefix-strip operation. It does not resolve symlinks
# or handle cases where target is not under base — in those cases the full
# target path is returned unchanged.
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

# Check if a path is absolute (starts with /).
# Use this to validate user-supplied paths or decide whether to prepend
# a working directory before using them.
#
# Usage: fs::path::is_absolute path
#   if fs::path::is_absolute "$input"; then ...
#
# Returns: 0 if the path starts with /, 1 otherwise
fs::path::is_absolute() {
    [[ "$1" == /* ]]
}

# Check if a path is relative (does not start with /).
# Use this as the inverse of fs::path::is_absolute when routing logic
# that needs to handle relative and absolute paths differently.
#
# Usage: fs::path::is_relative path
#   if fs::path::is_relative "$input"; then input="$(pwd)/$input"; fi
#
# Returns: 0 if the path does not start with /, 1 otherwise
fs::path::is_relative() {
    [[ "$1" != /* ]]
}

# ==============================================================================
# FILE / DIR CHECKS
# ==============================================================================

# Test properties of a file or directory path.
# These are thin wrappers around standard Bash test operators, grouped here
# for consistency with the rest of the fs:: module.
#
# Usage: fs::exists path | fs::is_file path | fs::is_dir path | ...
#   if fs::is_file "$config"; then ...
#   if fs::is_empty "$logfile"; then ...
#
# Returns: 0 if the condition is true, 1 otherwise
#
# Note: fs::is_empty returns 0 for both empty files (zero bytes) and empty
# directories (no entries). Directories containing only hidden files are
# considered non-empty.
fs::exists()        { [[ -e "$1" ]]; }
fs::is_file()       { [[ -f "$1" ]]; }
fs::is_dir()        { [[ -d "$1" ]]; }
fs::is_symlink()    { [[ -L "$1" ]]; }
fs::is_readable()   { [[ -r "$1" ]]; }
fs::is_writable()   { [[ -w "$1" ]]; }
fs::is_executable() { [[ -x "$1" ]]; }
fs::is_empty()      { [[ -f "$1" && ! -s "$1" ]] || [[ -d "$1" && -z "$(ls -A "$1" 2>/dev/null)" ]]; }

# Check if two paths resolve to the same underlying file by comparing inodes.
# Use this to detect hard links or to confirm that two paths (possibly through
# different symlinks) point to the same physical file.
#
# Usage: fs::is_same path1 path2
#   if fs::is_same "$src" "$dst"; then echo "same file, skipping copy"; fi
#
# Returns: 0 if both paths share the same device and inode number, 1 otherwise
fs::is_same() {
    [[ "$(stat -c '%d:%i' "$1" 2>/dev/null)" == "$(stat -c '%d:%i' "$2" 2>/dev/null)" ]]
}

# ==============================================================================
# FILE INFO
# ==============================================================================

# Return the size of a file in bytes.
# Use this when you need an exact byte count for validation, comparison,
# or arithmetic — e.g. checking a file is non-empty or within a size limit.
#
# Usage: fs::size path
#   bytes=$(fs::size "/var/log/app.log")
#
# Returns: echoes the file size as an integer; returns 0
fs::size() {
    stat -c '%s' "$1" 2>/dev/null || wc -c < "$1" 2>/dev/null
}

# Return the size of a file in a human-readable format (e.g. 4.2MiB).
# Use this for display purposes in output, logs, or summaries where raw
# byte counts would be hard to read.
#
# Usage: fs::size::human path
#   fs::size::human "/var/log/app.log"   # → e.g. "1.3MiB"
#
# Returns: echoes a human-readable size string with IEC unit suffix; returns 0
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

# Return the last-modified time of a file as a Unix timestamp (seconds since epoch).
# Use this for comparisons, sorting, or checking whether a file has changed
# since a known point in time.
#
# Usage: fs::modified path
#   mtime=$(fs::modified "/etc/hosts")
#
# Returns: echoes the Unix timestamp as an integer; returns 0
fs::modified() {
    stat -c '%Y' "$1" 2>/dev/null
}

# Return the last-modified time of a file in a human-readable format.
# Use this for display in logs or output where a raw timestamp would be unhelpful.
#
# Usage: fs::modified::human path
#   fs::modified::human "/etc/hosts"   # → e.g. "2024-01-15 10:23:44.000000000 +0000"
#
# Returns: echoes the formatted date/time string as reported by stat; returns 0
fs::modified::human() {
    stat -c '%y' "$1" 2>/dev/null
}

# Return the creation time of a file as a Unix timestamp.
# Use this when you need to know when a file was first created, rather than
# when it was last modified.
#
# Usage: fs::created path
#   created=$(fs::created "report.pdf")
#
# Returns: echoes the Unix timestamp; echoes 0 if the filesystem does not
# track creation time (common on Linux ext4)
#
# Note: Creation time (birth time) is not reliably available on all filesystems
# or Linux kernel versions. ext4 supports it from kernel 4.11+, but older
# systems and some network filesystems may always return 0.
fs::created() {
    stat -c '%W' "$1" 2>/dev/null
}

# Return the permissions of a file or directory as an octal string (e.g. "755").
# Use this when you need to check, store, or restore permissions programmatically.
#
# Usage: fs::permissions path
#   fs::permissions "/usr/bin/env"   # → "755"
#
# Returns: echoes the octal permission string; returns 0
fs::permissions() {
    stat -c '%a' "$1" 2>/dev/null
}

# Return the permissions of a file or directory in symbolic notation (e.g. "-rwxr-xr-x").
# Use this for human-readable permission display in output or reports.
#
# Usage: fs::permissions::symbolic path
#   fs::permissions::symbolic "/usr/bin/env"   # → "-rwxr-xr-x"
#
# Returns: echoes the symbolic permission string; returns 0
fs::permissions::symbolic() {
    stat -c '%A' "$1" 2>/dev/null
}

# Return the username of the file's owner.
# Use this for permission audits, access checks, or generating ownership reports.
#
# Usage: fs::owner path
#   fs::owner "/etc/passwd"   # → "root"
#
# Returns: echoes the owner's username; returns 0
fs::owner() {
    stat -c '%U' "$1" 2>/dev/null
}

# Return the group name of the file's owning group.
# Use this alongside fs::owner when auditing group-based access permissions.
#
# Usage: fs::owner::group path
#   fs::owner::group "/etc/passwd"   # → "root"
#
# Returns: echoes the group name; returns 0
fs::owner::group() {
    stat -c '%G' "$1" 2>/dev/null
}

# Return the inode number of a file.
# Use this for low-level file identity checks, detecting hard links, or
# tracking a file across renames (inode stays the same when a file is renamed).
#
# Usage: fs::inode path
#   fs::inode "/etc/hosts"   # → e.g. "1234567"
#
# Returns: echoes the inode number as an integer; returns 0
fs::inode() {
    stat -c '%i' "$1" 2>/dev/null
}

# Return the MIME type of a file based on its content (not just its extension).
# Use this to determine how to process or serve a file when its extension
# is absent, wrong, or untrustworthy.
#
# Usage: fs::mime_type path
#   fs::mime_type "photo.jpg"      # → "image/jpeg"
#   fs::mime_type "script.sh"      # → "text/x-shellscript"
#
# Returns: echoes the MIME type string; echoes "unknown" if the file command
# is not available
fs::mime_type() {
    if runtime::has_command file; then
        file --mime-type -b "$1" 2>/dev/null
    else
        echo "unknown"
    fi
}

# Return the number of hard links pointing to a file.
# A count greater than 1 means the file's data is referenced from multiple
# directory entries. Use this to detect shared inodes or audit link structure.
#
# Usage: fs::link_count path
#   fs::link_count "/etc/hosts"   # → "1"
#
# Returns: echoes the hard link count as an integer; returns 0
fs::link_count() {
    stat -c '%h' "$1" 2>/dev/null
}

# Return the immediate target of a symlink (one hop only, not fully resolved).
# Use this when you need to read or display the link's literal destination
# rather than the final file it ultimately points to.
#
# Usage: fs::symlink::target path
#   fs::symlink::target "/usr/bin/python"   # → "python3.11"
#
# Returns: echoes the link's target path; returns 0; echoes nothing if path
# is not a symlink
fs::symlink::target() {
    readlink "$1" 2>/dev/null
}

# Return the fully resolved path a symlink ultimately points to, following
# any chain of intermediate symlinks. Use this when you need the real file
# path regardless of how many symlink hops are involved.
#
# Usage: fs::symlink::resolve path
#   fs::symlink::resolve "/usr/bin/python"   # → "/usr/bin/python3.11"
#
# Returns: echoes the canonical absolute path; returns 0; echoes nothing if
# the path cannot be resolved
fs::symlink::resolve() {
    readlink -f "$1" 2>/dev/null
}

# ==============================================================================
# OPERATIONS
# ==============================================================================

# Copy a file or directory to a destination path.
# Works recursively for directories. Use this as a straightforward wrapper
# when you need a copy operation that handles both files and dirs uniformly.
#
# Usage: fs::copy src dst
#   fs::copy "/etc/nginx/nginx.conf" "/tmp/nginx.conf.bak"
#   fs::copy "/etc/nginx" "/tmp/nginx-backup"
#
# Returns: 0 on success, 1 on failure
fs::copy() {
    cp -r "$1" "$2"
}

# Move or rename a file or directory.
# Use this to relocate files between directories or rename them in place.
#
# Usage: fs::move src dst
#   fs::move "/tmp/work.txt" "/home/user/final.txt"
#
# Returns: 0 on success, 1 on failure
fs::move() {
    mv "$1" "$2"
}

# Delete a file or directory, including all contents if it is a directory.
# Use this when you are sure you want to remove the target completely.
#
# Usage: fs::delete path
#   fs::delete "/tmp/scratch"
#
# Returns: 0 on success, 1 on failure
#
# Warning: Deletes recursively and permanently with no confirmation. Consider
# fs::trash if you want a recoverable soft-delete instead.
fs::delete() {
    rm -rf "$1"
}

# Create a directory, including any missing parent directories.
# Use this instead of mkdir to avoid errors when the directory already exists
# or when you need to create a deep path in one call.
#
# Usage: fs::mkdir path
#   fs::mkdir "/var/app/logs/2024"
#
# Returns: 0 on success, 1 on failure
fs::mkdir() {
    mkdir -p "$1"
}

# Create a file if it doesn't exist, or update its timestamp if it does.
# Use this to ensure a file exists before reading it, or to signal that
# something happened at a point in time without writing any content.
#
# Usage: fs::touch path
#   fs::touch "/tmp/last-run.lock"
#
# Returns: 0 on success, 1 on failure
fs::touch() {
    touch "$1"
}

# Create a symbolic link pointing to a target.
# Use this to create aliases, version-neutral paths, or shared references
# to a file without duplicating its content.
#
# Usage: fs::symlink target link_name
#   fs::symlink "/opt/app-1.2.3" "/opt/app"
#
# Returns: 0 on success, 1 on failure
fs::symlink() {
    ln -s "$1" "$2"
}

# Create a hard link — a second directory entry pointing to the same inode.
# Use this when you want two paths to share the exact same file data, where
# deleting one path won't remove the file until all hard links are gone.
#
# Usage: fs::hardlink src link_name
#   fs::hardlink "data.csv" "data-backup.csv"
#
# Returns: 0 on success, 1 on failure
#
# Note: Hard links cannot span filesystems or point to directories.
fs::hardlink() {
    ln "$1" "$2"
}

# Rename a file within its current directory, keeping its location the same.
# Use this when you want to change just the name without specifying the full
# destination path.
#
# Usage: fs::rename old_path new_name
#   fs::rename "/var/log/app.log" "app.log.old"
#
# Returns: 0 on success, 1 on failure
fs::rename() {
    local dir
    dir="$(fs::path::dirname "$1")"
    mv "$1" "$dir/$2"
}

# Move a file to the user's trash directory instead of permanently deleting it.
# Use this as a safer alternative to fs::delete when you want the operation
# to be recoverable, following the XDG trash spec.
#
# Usage: fs::trash path
#   fs::trash "/tmp/old-report.pdf"
#
# Returns: 0 on success, 1 on failure
#
# Note: Files are moved to ~/.local/share/Trash/files/ with a Unix timestamp
# appended to the name to avoid collisions. This does not write a .trashinfo
# metadata file, so some desktop trash managers may not display the entry.
fs::trash() {
    local trash_dir="${HOME}/.local/share/Trash/files"
    mkdir -p "$trash_dir"
    mv "$1" "$trash_dir/$(fs::path::basename "$1").$(date +%s)"
}

# ==============================================================================
# TEMP FILES
# ==============================================================================

# Create a temporary file with a unique name and print its path.
# Use this when you need scratch space for intermediate data that should
# not persist after the script finishes.
#
# Usage: tmpfile=$(fs::temp::file [prefix])
#   tmp=$(fs::temp::file "myapp")   # → e.g. /tmp/myapp.aX3kqZ
#
# Returns: echoes the path of the created temp file; returns 0
#
# Note: Does not register automatic cleanup — use fs::temp::file::auto if you
# want the file removed on script exit.
fs::temp::file() {
    local prefix="${1:-fsbshf}"
    mktemp "/tmp/${prefix}.XXXXXX"
}

# Create a temporary directory with a unique name and print its path.
# Use this when you need a scratch directory for multiple temp files or
# intermediate build artefacts.
#
# Usage: tmpdir=$(fs::temp::dir [prefix])
#   tmpd=$(fs::temp::dir "myapp")   # → e.g. /tmp/myapp.bK7mzQ
#
# Returns: echoes the path of the created temp directory; returns 0
#
# Note: Does not register automatic cleanup — use fs::temp::dir::auto if you
# want the directory removed on script exit.
fs::temp::dir() {
    local prefix="${1:-fsbshf}"
    mktemp -d "/tmp/${prefix}.XXXXXX"
}

# Create a temporary file and register it for automatic deletion when the script exits.
# Use this in preference to fs::temp::file whenever you want guaranteed cleanup
# without having to manage the trap yourself.
#
# Usage: fs::temp::file::auto [prefix]
#   tmp=$(fs::temp::file::auto "myapp")
#
# Returns: echoes the path of the created temp file; returns 0
#
# Note: Registers a trap on EXIT. If your script already has an EXIT trap,
# this will replace it — combine traps manually if you need both.
fs::temp::file::auto() {
    local tmp
    tmp=$(fs::temp::file "$1")
    trap "rm -f '$tmp'" EXIT
    echo "$tmp"
}

# Create a temporary directory and register it for automatic deletion when the script exits.
# Use this in preference to fs::temp::dir whenever you want guaranteed cleanup
# without having to manage the trap yourself.
#
# Usage: fs::temp::dir::auto [prefix]
#   tmpd=$(fs::temp::dir::auto "myapp")
#
# Returns: echoes the path of the created temp directory; returns 0
#
# Note: Registers a trap on EXIT. If your script already has an EXIT trap,
# this will replace it — combine traps manually if you need both.
fs::temp::dir::auto() {
    local tmp
    tmp=$(fs::temp::dir "$1")
    trap "rm -rf '$tmp'" EXIT
    echo "$tmp"
}

# ==============================================================================
# READING / WRITING
# ==============================================================================

# Read and print the entire contents of a file.
# Use this as a simple named wrapper around cat when reading a file into
# a variable or piping it to another command.
#
# Usage: fs::read path
#   content=$(fs::read "/etc/hosts")
#
# Returns: echoes the file contents; returns 0
fs::read() {
    cat "$1"
}

# Write content to a file, replacing any existing content.
# Use this for simple, atomic single-value writes. For multi-line content
# or content ending in a newline, use fs::writeln.
#
# Usage: fs::write path content
#   fs::write "/tmp/config.txt" "debug=true"
#
# Returns: 0 on success, 1 on failure
#
# Warning: Overwrites the file completely. Existing content is lost.
fs::write() {
    printf '%s' "$2" > "$1"
}

# Write content to a file followed by a newline, replacing any existing content.
# Use this when writing a single line that should end with a newline, as most
# text tools expect.
#
# Usage: fs::writeln path content
#   fs::writeln "/tmp/status.txt" "ready"
#
# Returns: 0 on success, 1 on failure
#
# Warning: Overwrites the file completely. Existing content is lost.
fs::writeln() {
    printf '%s\n' "$2" > "$1"
}

# Append content to a file without a trailing newline.
# Use this to add raw data to a file where newline control matters,
# such as building a file byte-by-byte or appending binary-safe content.
#
# Usage: fs::append path content
#   fs::append "/tmp/output.txt" "more data"
#
# Returns: 0 on success, 1 on failure
fs::append() {
    printf '%s' "$2" >> "$1"
}

# Append a line of content to a file with a trailing newline.
# Use this for writing log entries, adding lines to a config, or any
# case where each appended item should be on its own line.
#
# Usage: fs::appendln path content
#   fs::appendln "/var/log/deploy.log" "Deploy started at $(date)"
#
# Returns: 0 on success, 1 on failure
fs::appendln() {
    printf '%s\n' "$2" >> "$1"
}

# Read a specific line from a file by its line number (1-indexed).
# Use this when you need to extract a single known line, such as a header
# row or a config value at a fixed position.
#
# Usage: fs::line path line_number
#   fs::line "/etc/passwd" 1
#
# Returns: echoes the content of the specified line; returns 0
fs::line() {
    sed -n "${2}p" "$1"
}

# Read a range of lines from a file (inclusive).
# Use this to extract a block of lines such as a section of a config file
# or a slice of a log.
#
# Usage: fs::lines path start end
#   fs::lines "/var/log/app.log" 10 20
#
# Returns: echoes the lines from start to end; returns 0
fs::lines() {
    sed -n "${2},${3}p" "$1"
}

# Count the number of lines in a file.
# Use this to validate file length, check if output was written, or loop
# over a file by index.
#
# Usage: fs::line_count path
#   n=$(fs::line_count "/etc/hosts")
#
# Returns: echoes the line count as an integer; returns 0
fs::line_count() {
    wc -l < "$1"
}

# Count the number of words in a file.
# Use this for quick content metrics or to check that generated output
# meets a minimum word count.
#
# Usage: fs::word_count path
#   fs::word_count "report.txt"
#
# Returns: echoes the word count as an integer; returns 0
fs::word_count() {
    wc -w < "$1"
}

# Count the number of bytes (characters) in a file.
# Use this to get the exact byte size of a file's content, useful when
# setting Content-Length headers or validating file sizes.
#
# Usage: fs::char_count path
#   fs::char_count "data.bin"
#
# Returns: echoes the byte count as an integer; returns 0
fs::char_count() {
    wc -c < "$1"
}

# Check if a file contains a literal string.
# Use this to test for the presence of a config value, a flag, or any
# fixed text before acting on a file.
#
# Usage: fs::contains path string
#   if fs::contains "/etc/fstab" "noatime"; then ...
#
# Returns: 0 if the string is found, 1 if not
fs::contains() {
    grep -qF "$2" "$1" 2>/dev/null
}

# Check if a file contains a match for a regular expression.
# Use this when a fixed-string check isn't flexible enough — for example,
# checking that a version line matches a semver pattern.
#
# Usage: fs::matches path regex
#   if fs::matches "version.txt" "^[0-9]+\.[0-9]+"; then ...
#
# Returns: 0 if the regex matches any line, 1 if not
fs::matches() {
    grep -qE "$2" "$1" 2>/dev/null
}

# Replace all occurrences of a string in a file, editing the file in place.
# Use this to patch config files, update version strings, or bulk-replace
# a value across a file without a temporary copy.
#
# Usage: fs::replace path old new
#   fs::replace "/etc/app.conf" "localhost" "10.0.0.5"
#
# Returns: 0 on success, 1 on failure
#
# Warning: Edits the file in place using sed -i. The original content is not
# preserved. Back up the file first if you need to recover the original.
fs::replace() {
    sed -i "s|${2}|${3}|g" "$1"
}

# Prepend content as a new line at the top of a file.
# Use this to insert a shebang, a header comment, or a record at the
# beginning of an existing file.
#
# Usage: fs::prepend path content
#   fs::prepend "script.sh" "#!/usr/bin/env bash"
#
# Returns: 0 on success, 1 on failure
fs::prepend() {
    local tmp
    tmp=$(fs::temp::file)
    printf '%s\n' "$2" | cat - "$1" > "$tmp"
    mv "$tmp" "$1"
}

# ==============================================================================
# DIRECTORY OPERATIONS
# ==============================================================================

# List the contents of a directory, one entry per line.
# Use this as a scriptable alternative to ls when you need clean, one-per-line
# output without colour codes or formatting.
#
# Usage: fs::ls [path]
#   fs::ls "/etc"
#   fs::ls   # defaults to current directory
#
# Returns: echoes filenames one per line; returns 0
fs::ls() {
    ls -1 "${1:-.}"
}

# List directory contents including hidden files (dotfiles).
# Use this when you need to see or process files whose names start with a dot,
# such as .gitignore, .env, or other config files.
#
# Usage: fs::ls::all [path]
#   fs::ls::all "/home/user"
#
# Returns: echoes filenames one per line including hidden entries; returns 0
fs::ls::all() {
    ls -1A "${1:-.}"
}

# List only regular files in a directory (no subdirectories or symlinks).
# Use this when you want to iterate over files without accidentally
# descending into or processing directories.
#
# Usage: fs::ls::files [path]
#   for f in $(fs::ls::files "/var/log"); do ...
#
# Returns: echoes filenames (not full paths) one per line; returns 0
fs::ls::files() {
    find "${1:-.}" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep -v '/$'
}

# List only subdirectories in a directory (no files or symlinks).
# Use this when you need to iterate over subdirectories, such as processing
# per-service config folders or per-user home directories.
#
# Usage: fs::ls::dirs [path]
#   for d in $(fs::ls::dirs "/home"); do ...
#
# Returns: echoes directory names (not full paths) one per line; returns 0
fs::ls::dirs() {
    find "${1:-.}" -maxdepth 1 -type d -not -path "${1:-.}" -printf '%f\n' 2>/dev/null || \
    ls -1p "${1:-.}" | grep '/$' | tr -d '/'
}

# Recursively search for files and directories matching a name pattern.
# Use this to locate files by name across a directory tree, supporting
# shell glob patterns like "*.log" or "config.*".
#
# Usage: fs::find path pattern
#   fs::find "/var/log" "*.log"
#
# Returns: echoes matching paths one per line; returns 0
fs::find() {
    find "${1:-.}" -name "$2" 2>/dev/null
}

# Recursively find entries of a specific type within a directory.
# Use this to list all files, all directories, or all symlinks under a path
# without mixing types.
#
# Usage: fs::find::type path type
#   fs::find::type "/etc" f    # regular files only
#   fs::find::type "/etc" d    # directories only
#   fs::find::type "/etc" l    # symlinks only
#
# Returns: echoes matching paths one per line; returns 0
fs::find::type() {
    find "${1:-.}" -type "$2" 2>/dev/null
}

# Find files modified within the last n minutes.
# Use this to detect recently changed files — for example, checking whether
# a watched config was updated or finding files created during a recent job.
#
# Usage: fs::find::recent path [minutes]
#   fs::find::recent "/var/log" 30    # files changed in last 30 minutes
#   fs::find::recent "/tmp"           # defaults to last 60 minutes
#
# Returns: echoes matching file paths one per line; returns 0
fs::find::recent() {
    find "${1:-.}" -type f -mmin "-${2:-60}" 2>/dev/null
}

# Find files larger than a given size in bytes.
# Use this to identify large files consuming disk space or to validate that
# generated output exceeds a minimum expected size.
#
# Usage: fs::find::larger_than path bytes
#   fs::find::larger_than "/home/user" 1048576   # files over 1MB
#
# Returns: echoes matching file paths one per line; returns 0
fs::find::larger_than() {
    find "${1:-.}" -type f -size "+${2}c" 2>/dev/null
}

# Find files smaller than a given size in bytes.
# Use this to identify suspiciously small files, zero-byte outputs, or
# incomplete downloads.
#
# Usage: fs::find::smaller_than path bytes
#   fs::find::smaller_than "/var/spool" 1024   # files under 1KB
#
# Returns: echoes matching file paths one per line; returns 0
fs::find::smaller_than() {
    find "${1:-.}" -type f -size "-${2}c" 2>/dev/null
}

# Return the total disk usage of a directory in bytes.
# Use this to check how much space a directory is consuming before archiving,
# cleaning, or enforcing a quota.
#
# Usage: fs::dir::size [path]
#   bytes=$(fs::dir::size "/var/log")
#
# Returns: echoes the total size in bytes; returns 0
fs::dir::size() {
    du -sb "${1:-.}" 2>/dev/null | awk '{print $1}'
}

# Return the total disk usage of a directory in human-readable format.
# Use this for display in reports or summaries where raw byte counts
# are not user-friendly.
#
# Usage: fs::dir::size::human [path]
#   fs::dir::size::human "/var/log"   # → e.g. "1.2G"
#
# Returns: echoes a human-readable size string (e.g. "4.2G"); returns 0
fs::dir::size::human() {
    du -sh "${1:-.}" 2>/dev/null | awk '{print $1}'
}

# Count the number of entries (files and subdirectories) directly inside a directory.
# Use this to check whether a directory has been populated, or to enforce
# limits on the number of items in a folder.
#
# Usage: fs::dir::count [path]
#   fs::dir::count "/etc/nginx/conf.d"
#
# Returns: echoes the entry count as an integer (not recursive); returns 0
fs::dir::count() {
    find "${1:-.}" -maxdepth 1 -not -path "${1:-.}" 2>/dev/null | wc -l
}

# Check if a directory contains no entries (files or subdirectories).
# Use this to skip processing empty directories or to verify that a
# cleanup operation left nothing behind.
#
# Usage: fs::dir::is_empty [path]
#   if fs::dir::is_empty "/tmp/work"; then rmdir "/tmp/work"; fi
#
# Returns: 0 if the directory is empty, 1 if it contains any entries
fs::dir::is_empty() {
    [[ -z "$(ls -A "${1:-.}" 2>/dev/null)" ]]
}

# ==============================================================================
# WATCHING
# ==============================================================================

# Watch a file for changes and call a callback function each time it is modified.
# Use this to trigger reloads, notifications, or processing steps whenever
# a file is updated — for example, restarting a service when its config changes.
#
# Usage: fs::watch path callback [interval_seconds]
#   on_change() { echo "$1 was modified"; }
#   fs::watch "/etc/app.conf" on_change 2
#
# Returns: runs indefinitely; the callback receives the watched path as $1
#
# Warning: Runs an infinite loop — it will block the current shell until
# interrupted. Run in the background with & or in a subshell if needed.
fs::watch() {
    local path="$1" callback="$2" interval="${3:-1}"
    local last_modified
    last_modified=$(fs::modified "$path")

    while true; do
        sleep "$interval"
        local current
        current=$(fs::modified "$path")
        if [[ "$current" != "$last_modified" ]]; then
            last_modified="$current"
            "$callback" "$path"
        fi
    done
}

# Watch a file for changes for up to a maximum number of seconds.
# Use this when you want the change-watching behaviour of fs::watch but need
# it to stop automatically — for example, waiting for a lock file to update
# during a build, with a deadline.
#
# Usage: fs::watch::timeout path callback timeout [interval]
#   fs::watch::timeout "/tmp/job.status" on_change 60 2
#
# Returns: exits after timeout seconds; the callback receives the watched path as $1
fs::watch::timeout() {
    local path="$1" callback="$2" timeout="$3" interval="${4:-1}"
    local elapsed=0
    local last_modified
    last_modified=$(fs::modified "$path")

    while (( elapsed < timeout )); do
        sleep "$interval"
        (( elapsed += interval ))
        local current
        current=$(fs::modified "$path")
        if [[ "$current" != "$last_modified" ]]; then
            last_modified="$current"
            "$callback" "$path"
        fi
    done
}

# ==============================================================================
# CHECKSUMS
# ==============================================================================

# Compute the MD5 hash of a file.
# Use this for quick integrity checks or checksums where cryptographic
# security is not required (e.g. detecting accidental corruption).
#
# Usage: fs::checksum::md5 path
#   fs::checksum::md5 "archive.tar.gz"   # → e.g. "d41d8cd98f00b204e9800998ecf8427e"
#
# Returns: echoes the hex digest string; returns 0
#
# Note: Uses md5sum on Linux or md5 on macOS. Returns nothing if neither is available.
fs::checksum::md5() {
    if runtime::has_command md5sum; then
        md5sum "$1" | awk '{print $1}'
    elif runtime::has_command md5; then
        md5 -q "$1"
    fi
}

# Compute the SHA-1 hash of a file.
# Use this when an upstream system or tool requires SHA-1 checksums for
# verification — note that SHA-1 is no longer considered cryptographically secure.
#
# Usage: fs::checksum::sha1 path
#   fs::checksum::sha1 "package.tar.gz"
#
# Returns: echoes the hex digest string; returns 0
#
# Note: Uses sha1sum on Linux or shasum on macOS. Returns nothing if neither is available.
fs::checksum::sha1() {
    if runtime::has_command sha1sum; then
        sha1sum "$1" | awk '{print $1}'
    elif runtime::has_command shasum; then
        shasum -a 1 "$1" | awk '{print $1}'
    fi
}

# Compute the SHA-256 hash of a file.
# Use this for secure integrity verification — verifying downloaded archives,
# signing artefacts, or comparing file content reliably.
#
# Usage: fs::checksum::sha256 path
#   fs::checksum::sha256 "installer.pkg"
#
# Returns: echoes the hex digest string; returns 0
#
# Note: Uses sha256sum on Linux or shasum -a 256 on macOS. Returns nothing if neither is available.
fs::checksum::sha256() {
    if runtime::has_command sha256sum; then
        sha256sum "$1" | awk '{print $1}'
    elif runtime::has_command shasum; then
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

# Check if two files have identical content by comparing their SHA-256 hashes.
# Use this to detect duplicates, verify that a copy succeeded, or confirm
# that a file hasn't changed between two points in time.
#
# Usage: fs::is_identical path1 path2
#   if fs::is_identical "original.conf" "backup.conf"; then echo "no changes"; fi
#
# Returns: 0 if both files produce the same SHA-256 hash, 1 otherwise
#
# Note: For a faster check when you only care about inode identity (hard links
# or the exact same path), use fs::is_same instead.
fs::is_identical() {
    local sum1 sum2
    sum1=$(fs::checksum::sha256 "$1")
    sum2=$(fs::checksum::sha256 "$2")
    [[ "$sum1" == "$sum2" ]]
}

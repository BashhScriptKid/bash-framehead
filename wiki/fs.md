# `fs`

Filesystem operations — path manipulation, file/directory checks, metadata, I/O, temp files, directory listing, find, watch, and checksums. **79 functions.** No `::fast` variants.

---

## Path Manipulation

| Function | Description |
|----------|-------------|
| `fs::path::join` | Join path components together |
| `fs::path::basename` | Get filename from path (like `basename`) |
| `fs::path::dirname` | Get directory from path (like `dirname`) |
| `fs::path::extension` | Get file extension (without dot) |
| `fs::path::extensions` | Get all extensions for multi-part (e.g., `.tar.gz`) |
| `fs::path::stem` | Strip extension from filename |
| `fs::path::absolute` | Get absolute path (resolves `.` and `..` without requiring the path to exist) |
| `fs::path::relative` | Get path relative to a base directory |
| `fs::path::is_absolute` | Check if a path is absolute |
| `fs::path::is_relative` | Check if a path is relative |

```bash
fs::path::join "/usr" "local" "bin"     # → /usr/local/bin
fs::path::basename "/etc/nginx/nginx.conf"  # → nginx.conf
fs::path::extension "file.tar.gz"       # → gz
fs::path::extensions "file.tar.gz"      # → tar.gz
fs::path::absolute "./subdir"           # → /home/user/current/subdir
fs::path::relative "/a/b/c" "/a"       # → b/c
```

## File / Directory Checks

All return exit code 0 (true) or 1 (false).

| Function | Description |
|----------|-------------|
| `fs::exists` | Check if a path exists |
| `fs::is_file` | Check if path is a regular file |
| `fs::is_dir` | Check if path is a directory |
| `fs::is_symlink` | Check if path is a symbolic link |
| `fs::is_readable` | Check if path is readable |
| `fs::is_writable` | Check if path is writable |
| `fs::is_executable` | Check if path is executable |
| `fs::is_empty` | Check if file or directory is empty |
| `fs::is_same` | Check if two paths resolve to the same file (inode comparison) |

```bash
if fs::is_dir "/etc"; then
    echo "It's a directory"
fi
```

## File Metadata

| Function | Description |
|----------|-------------|
| `fs::size` | File size in bytes |
| `fs::size::human` | Human-readable file size (e.g., `1.5M`) |
| `fs::modified` | Last modified time (unix timestamp) |
| `fs::modified::human` | Last modified time (human readable) |
| `fs::created` | Creation time (unix timestamp) |
| `fs::permissions` | Octal permissions (e.g., `755`) |
| `fs::permissions::symbolic` | Symbolic permissions (e.g., `-rwxr-xr-x`) |
| `fs::owner` | Owner username |
| `fs::owner::group` | Owner group |
| `fs::inode` | Inode number |
| `fs::mime_type` | MIME type |
| `fs::link_count` | Number of hard links |
| `fs::symlink::target` | Symlink target path |
| `fs::symlink::resolve` | Resolved symlink target (follows chain) |

## File Operations

| Function | Description |
|----------|-------------|
| `fs::copy` | Copy file or directory |
| `fs::move` | Move/rename file or directory |
| `fs::delete` | Delete file or directory |
| `fs::mkdir` | Create directory (including parents) |
| `fs::touch` | Touch a file (create or update timestamp) |
| `fs::symlink` | Create a symbolic link |
| `fs::hardlink` | Create a hard link |
| `fs::rename` | Rename just the filename, keeping directory |
| `fs::trash` | Safely delete to a trash directory |

```bash
fs::mkdir "/tmp/myapp/cache"
fs::copy "./config.ini" "./config.ini.bak"
fs::symlink "/usr/bin/python3" "/usr/local/bin/python"
fs::trash "./old_file.txt"
```

## Temp Files

| Function | Description |
|----------|-------------|
| `fs::temp::file` | Create a temporary file, print its path |
| `fs::temp::dir` | Create a temporary directory, print its path |
| `fs::temp::file::auto` | Create temp file with automatic cleanup on EXIT |
| `fs::temp::dir::auto` | Create temp dir with automatic cleanup on EXIT |

```bash
tmpfile=$(fs::temp::file "myapp-")
echo "working in $tmpfile"
# File is removed when script exits (if using ::auto variant)
```

## Reading & Writing

| Function | Description |
|----------|-------------|
| `fs::read` | Read entire file contents |
| `fs::write` | Write content to file (overwrites) |
| `fs::writeln` | Write content with trailing newline |
| `fs::append` | Append content to file |
| `fs::appendln` | Append content with newline |
| `fs::line` | Read a specific line number (1-indexed) |
| `fs::lines` | Read a range of lines |
| `fs::line_count` | Count lines in a file |
| `fs::word_count` | Count words in a file |
| `fs::char_count` | Count characters in a file |
| `fs::contains` | Check if file contains a string |
| `fs::matches` | Check if file matches a regex |
| `fs::replace` | Replace string in file (in-place) |
| `fs::prepend` | Prepend content to file |

```bash
fs::write "/tmp/status" "ready"
fs::appendln "/var/log/app.log" "startup complete"
fs::contains "/etc/hosts" "localhost" && echo "found"
fs::replace "/tmp/config" "dev" "prod"
```

## Directory Operations

| Function | Description |
|----------|-------------|
| `fs::ls` | List directory contents (one per line) |
| `fs::ls::all` | List including hidden files |
| `fs::ls::files` | List only files |
| `fs::ls::dirs` | List only directories |
| `fs::find` | Recursive find by name pattern |
| `fs::find::type` | Recursive find by type (`f`, `d`, `l`) |
| `fs::find::recent` | Find files modified within n minutes |
| `fs::find::larger_than` | Find files larger than n bytes |
| `fs::find::smaller_than` | Find files smaller than n bytes |
| `fs::dir::size` | Get total size of directory |
| `fs::dir::size::human` | Get total size of directory, human readable |
| `fs::dir::count` | Count items in directory |
| `fs::dir::is_empty` | Check if directory is empty |

## File Watching

| Function | Description |
|----------|-------------|
| `fs::watch` | Watch a file for changes, run callback on change |
| `fs::watch::timeout` | Watch with a timeout in seconds |

```bash
fs::watch "/var/log/app.log" "echo 'log changed'" 2
```

## Checksums

| Function | Description |
|----------|-------------|
| `fs::checksum::md5` | MD5 checksum of a file |
| `fs::checksum::sha1` | SHA1 checksum of a file |
| `fs::checksum::sha256` | SHA256 checksum of a file |
| `fs::is_identical` | Check if two files are identical (by content) |

## Dependencies

- **Requires**: `runtime`
- **External tools**: `stat`, `find`, `diff` (for `fs::is_identical`), `md5sum`/`sha1sum`/`sha256sum` (for checksums)

# `pm`

Cross-distribution package manager abstraction. **5 functions.** Detects the system package manager via `runtime::pm` and dispatches to the appropriate command. No `::fast` variants.

---

## Supported Package Managers

| Manager | Distribution |
|---------|-------------|
| `apt` | Debian, Ubuntu, Mint |
| `pacman` | Arch, Manjaro, EndeavourOS |
| `dnf` | Fedora, RHEL 8+ |
| `yum` | RHEL 7, CentOS 7 |
| `zypper` | openSUSE |
| `apk` | Alpine Linux |
| `brew` | macOS Homebrew |
| `pkg` | FreeBSD |
| `xbps` | Void Linux |
| `nix` | NixOS |

## Functions

| Function | Description |
|----------|-------------|
| `pm::install` | Install one or more packages |
| `pm::sync` | Sync/refresh the remote package index |
| `pm::update` | Upgrade all installed packages to latest versions |
| `pm::uninstall` | Remove one or more packages |
| `pm::search` | Search available packages for a query |

```bash
# Install packages (distro-agnostic)
pm::install "git" "curl" "jq"

# Update package database
pm::sync

# Upgrade all packages
pm::update

# Search for a package
pm::search "python-requests"

# Remove packages
pm::uninstall "git"
```

## Error Handling

All functions return exit code 1 with an error message on stderr if the package manager cannot be detected:

```bash
if ! pm::install "nonexistent-package"; then
    echo "Installation failed"
fi
```

## Dependencies

- **Requires**: `runtime` (for `runtime::pm` detection)
- **External tools**: The appropriate system package manager must be available and the user must have sufficient privileges

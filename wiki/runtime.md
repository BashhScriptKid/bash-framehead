# `runtime`

The foundation module — required by all other modules. Provides shell state detection, OS/platform identification, and terminal capability queries. **54 functions.** Pure Bash builtins, no external dependencies.

## Shell State

| Function | Description |
|----------|-------------|
| `runtime::is_terminal` | Check if stdin, stdout, *and* stderr are connected to a terminal |
| `runtime::is_terminal::stdin` | Check if stdin is a terminal |
| `runtime::is_terminal::stdout` | Check if stdout is a terminal |
| `runtime::is_terminal::stderr` | Check if stderr is a terminal |
| `runtime::is_traced` | Check if `set -x` (xtrace) is active |
| `runtime::is_verbose` | Check if `set -v` (verbose) is active |
| `runtime::errexit_enabled` | Check if `set -e` (errexit) is active |
| `runtime::nounset_enabled` | Check if `set -u` (nounset) is active |
| `runtime::noclobber_enabled` | Check if `set -C` (noclobber) is active |
| `runtime::is_interactive` | Check if the shell is interactive |
| `runtime::has_flag` | Check if a specific shell flag is set in `$-` |
| `runtime::is_login` | Check if this is a login shell |
| `runtime::is_sourced` | Check if the script is being sourced (not executed directly) |
| `runtime::is_bash` | Check if running under Bash |
| `runtime::is_pipe` | Check if stdin is coming from a pipe or redirect |
| `runtime::is_redirected` | Check if any standard descriptor is redirected |
| `runtime::is_subshell` | Check if we're in a subshell |
| `runtime::job_controlled` | Check if job control is active |
| `runtime::debug_trapped` | Check if a DEBUG trap is set |
| `runtime::braceexpand_enabled` | Check if brace expansion is enabled |
| `runtime::histexpand_enabled` | Check if history expansion (`!`) is enabled |
| `runtime::physical_cd_enabled` | Check if `cd -P` behavior is active |

```bash
# Guard interactive-only behavior
if runtime::is_interactive && runtime::is_terminal; then
    echo "Running in an interactive terminal"
fi

# Check for pipe input
if runtime::is_pipe; then
    echo "stdin is being piped"
fi

# Detect sourced vs executed
if runtime::is_sourced; then
    echo "This script was sourced"
fi
```

## Privilege & Environment

| Function | Description |
|----------|-------------|
| `runtime::has_command` | Check if a command is available on `$PATH` |
| `runtime::is_root` | Check if running as root (UID 0) |
| `runtime::is_sudo` | Check if running under `sudo` |
| `runtime::is_ci` | Check if running in a CI environment |
| `runtime::is_container` | Check if running inside a container (Docker, LXC, etc.) |
| `runtime::is_virtualized` | Check if running inside a VM |

## Desktop & Display

| Function | Description |
|----------|-------------|
| `runtime::is_desktop` | Check if a desktop environment is running |
| `runtime::de` | Return the desktop environment name (GNOME, KDE, XFCE, etc.) |
| `runtime::wm` | Return the window manager name |
| `runtime::is_wayland` | Check if running under Wayland |
| `runtime::is_x11` | Check if running under X11 |

## System Detection

| Function | Description |
|----------|-------------|
| `runtime::sysinit` | Detect init system (systemd, openrc, runit, etc.) |
| `runtime::kernel_version` | Return kernel version (numeric only) |
| `runtime::exec_root` | Detect execution root — physical system, chroot, or container |
| `runtime::is_wsl` | Check if running under WSL (Windows Subsystem for Linux) |
| `runtime::os` | Return OS name (Linux, Darwin, etc.) |
| `runtime::arch` | Return CPU architecture (x86_64, aarch64, etc.) |
| `runtime::distro` | Return Linux distribution name |

## Bash Version

| Function | Description |
|----------|-------------|
| `runtime::bash_version` | Return full Bash version string |
| `runtime::bash_version::major` | Return major Bash version number |
| `runtime::is_minimum_bash` | Check if Bash version meets a minimum (defaults to 3) |

## Terminal Capabilities

| Function | Description |
|----------|-------------|
| `runtime::supports_color` | Check if terminal supports colour output |
| `runtime::supports_truecolor` | Check if terminal supports 24-bit true colour |
| `runtime::is_multiplexer` | Check if running inside a terminal multiplexer (tmux/screen) |
| `runtime::is_tmux` | Check if running inside tmux |
| `runtime::screen_session` | Check if running inside GNU screen |
| `runtime::is_ssh` | Check if connected via SSH |
| `runtime::ssh_client` | Return the SSH client IP |
| `runtime::is_tty` | Check if we have a controlling terminal |
| `runtime::tty_name` | Return the name of the controlling terminal |
| `runtime::is_pty` | Check if we're in a pseudo-terminal |

## Package Manager

| Function | Description |
|----------|-------------|
| `runtime::pm` | Detect the system package manager (apt, pacman, dnf, yum, zypper, apk, brew, pkg, xbps, nix) |

## Dependencies

- **Required by**: All other modules
- **Requires**: Nothing — pure Bash builtins

# Example: Writing a Robust Installer Script

Uses `runtime`, `pm`, `fs`, and `hardware` to build a setup script that works across Linux distros and macOS. It checks prerequisites, verifies disk space, installs dependencies via the system package manager, and lays down config files.

This is the most complete worked example. The final script is ~80 lines and is usable as a real installer template.

## 1. OS and package manager detection

`runtime::os` tells you the OS family. `runtime::pm` returns the active package manager name. Together they replace a manual `if which apt-get` chain:

```bash
os=$(runtime::os)
pm=$(runtime::pm)

echo "Detected: $os ($pm)"

case "$os" in
    linux)   echo "Linux — proceeding." ;;
    darwin)  echo "macOS — proceeding." ;;
    *)
        echo "Unsupported OS: $os" >&2
        exit 1
        ;;
esac
```

`runtime::pm` returns `"apt"`, `"pacman"`, `"dnf"`, `"yum"`, `"zypper"`, `"apk"`, `"xbps"`, `"emerge"`, `"brew"`, `"nix"`, or `"unknown"`.

## 2. Privilege check

Before doing anything destructive, check whether we have the access we need:

```bash
if ! runtime::is_root; then
    echo "Not running as root. Re-execing with privilege escalation..."
    runtime::exec_root "$0" "$@"
    exit $?
fi
```

`runtime::exec_root` tries `sudo`, then `pkexec`, then `doas`, then `su` — whatever is available on the system. If none work, it returns non-zero.

For scripts that only need root for some operations (like `pm::install`), check at the point of need rather than at the top.

## 3. Disk space check

Guard against running out of space mid-install:

```bash
MIN_SPACE_MB=512

available=$(hardware::partition::freeSpaceMB "$install_target")
if (( available < MIN_SPACE_MB )); then
    echo "Not enough disk space on $install_target." >&2
    echo "  Required: ${MIN_SPACE_MB}MB" >&2
    echo "  Available: ${available}MB" >&2
    exit 1
fi

echo "Disk space: ${available}MB available (>= ${MIN_SPACE_MB}MB required)"
```

`hardware::partition::freeSpaceMB` defaults to `/` if no mountpoint is given. Pass the install target explicitly if it's on a different partition.

## 4. Dependency installation

Sync the package index, then install. Skip packages that are already on PATH to avoid unnecessary work:

```bash
install_if_missing() {
    local pkg="$1" cmd="${2:-$1}"
    if runtime::has_command "$cmd"; then
        echo "  $cmd already installed — skipping."
        return 0
    fi
    echo "  Installing $pkg..."
    pm::install "$pkg"
}

echo "Updating package lists..."
pm::sync

echo "Installing dependencies..."
install_if_missing git
install_if_missing curl
install_if_missing jq
```

## 5. Config file placement

Lay down config files. Don't overwrite existing ones without asking:

```bash
install_config() {
    local src="$1" dest="$2"

    fs::mkdir "$(fs::path::dirname "$dest")"

    if fs::exists "$dest"; then
        echo "  Config exists: $dest"
        echo "  Backing up to ${dest}.bak"
        fs::copy "$dest" "${dest}.bak"
    fi

    fs::writeln "$dest" "$(fs::read "$src")"
    echo "  Installed: $dest"
}
```

`fs::path::dirname` returns the directory portion of a path — the same logic as the Unix `dirname` command, but it's a function call rather than a subshell.

## The complete installer

```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/bash_framehead.sh"

# ---------- configuration ----------
APP_NAME="myapp"
INSTALL_DIR="/opt/$APP_NAME"
CONFIG_DIR="/etc/$APP_NAME"
MIN_SPACE_MB=512

# ---------- helpers ----------
die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "  $*"; }

install_if_missing() {
    local pkg="$1" cmd="${2:-$1}"
    runtime::has_command "$cmd" && { info "$cmd already installed."; return 0; }
    info "Installing $pkg..."
    pm::install "$pkg"
}

install_config() {
    local src="$1" dest="$2"
    fs::mkdir "$(fs::path::dirname "$dest")"
    if fs::exists "$dest"; then
        info "Backing up $dest → ${dest}.bak"
        fs::copy "$dest" "${dest}.bak"
    fi
    fs::writeln "$dest" "$(fs::read "$src")"
    info "Installed: $dest"
}

# ---------- preamble ----------
echo "==> $APP_NAME installer"
echo ""

os=$(runtime::os)
pm=$(runtime::pm)
info "OS: $os  |  Package manager: $pm"

case "$os" in
    linux|darwin) ;;
    *) die "Unsupported OS: $os" ;;
esac

# ---------- privilege ----------
if ! runtime::is_root; then
    info "Re-execing with privilege escalation..."
    runtime::exec_root "$0" "$@"
    exit $?
fi

# ---------- disk space ----------
available=$(hardware::partition::freeSpaceMB "$INSTALL_DIR")
if (( available < MIN_SPACE_MB )); then
    die "Not enough space on $INSTALL_DIR (need ${MIN_SPACE_MB}MB, have ${available}MB)"
fi
info "Disk space: ${available}MB available"

# ---------- dependencies ----------
echo ""
echo "==> Dependencies"
pm::sync
install_if_missing git
install_if_missing curl
install_if_missing jq

# ---------- install ----------
echo ""
echo "==> Installing to $INSTALL_DIR"
fs::mkdir "$INSTALL_DIR"
fs::copy ./bin/* "$INSTALL_DIR/"

echo ""
echo "==> Configuring $CONFIG_DIR"
install_config ./config/app.conf "$CONFIG_DIR/app.conf"
install_config ./config/log.conf "$CONFIG_DIR/log.conf"

# ---------- done ----------
echo ""
echo "==> Done."
echo "    Binary: $INSTALL_DIR/$APP_NAME"
echo "    Config: $CONFIG_DIR/"
```

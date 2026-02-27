#!/usr/bin/env bash
# device.sh — bash-frameheader device lib
# Requires: runtime.sh (runtime::os, runtime::has_command)

# ==============================================================================
# INSPECTION
# ==============================================================================

# Check if a path points to a character device (e.g. /dev/tty, /dev/null).
# Use this when you need to distinguish character devices from regular files,
# block devices, or other special files before operating on them.
#
# Usage: device::is_device path
#   if device::is_device "/dev/tty0"; then ...
#
# Returns: 0 if the path is a character device, 1 otherwise
device::is_device() {
    [[ -c "$1" ]]
}

# Check if a path points to a block device (e.g. /dev/sda, /dev/nvme0n1).
# Use this to confirm a path is a storage device before passing it to
# partition, format, or mount operations.
#
# Usage: device::is_block path
#   if device::is_block "/dev/sda"; then ...
#
# Returns: 0 if the path is a block device, 1 otherwise
device::is_block() {
    [[ -b "$1" ]]
}

# Check if a device path is writable by the current process.
# Use this before attempting to write to a device to avoid permission errors
# or writes to read-only media.
#
# Usage: device::is_writeable path
#   if device::is_writeable "/dev/sdb"; then ...
#
# Returns: 0 if the device is writable, 1 otherwise
device::is_writeable() {
    [[ -w "$1" ]]
}

# Check if a device path is readable by the current process.
# Use this before attempting to read from a device to catch permission issues
# early and give a clear error rather than a cryptic read failure.
#
# Usage: device::is_readable path
#   if device::is_readable "/dev/sda"; then ...
#
# Returns: 0 if the device is readable, 1 otherwise
device::is_readable() {
    [[ -r "$1" ]]
}

# Check if a device path exists as either a block or character device.
# Use this as a general existence check when you don't care about the specific
# device type, just whether the path refers to an actual device node.
#
# Usage: device::exists path
#   if device::exists "/dev/sda"; then ...
#
# Returns: 0 if the path is a block or character device, 1 otherwise
device::exists() {
    [[ -b "$1" || -c "$1" ]]
}

# Check if any running processes have open file handles on a device via lsof.
# Use this before unmounting or ejecting a device to detect if something is
# actively using it and would be disrupted.
#
# Usage: device::has_processes path
#   if device::has_processes "/dev/sdb"; then echo "device is in use"; fi
#
# Returns: 0 if at least one process has the device open, 1 if none do or
# if lsof is unavailable
#
# Note: Requires lsof. Returns 1 (not an error) if lsof is not installed.
device::has_processes() {
    runtime::has_command lsof || return 1
    lsof -t "$1" >/dev/null 2>&1
}

# Check if any process has the device open by scanning /proc/PID/fd symlinks.
# Use this as a lighter alternative to device::has_processes when lsof is not
# available, such as in minimal or embedded Linux environments.
#
# Usage: device::is_occupied path
#   if device::is_occupied "/dev/sda"; then echo "device is busy"; fi
#
# Returns: 0 if a process has the device open, 1 otherwise
#
# Note: Linux-only — depends on /proc being present. Does not work on macOS.
device::is_occupied() {
    find /proc/[0-9]*/fd -lname "*${1#/dev/}" 2>/dev/null | head -1 | grep -q .
}

# Check if a block device is currently mounted.
# Use this before mounting a device (to avoid double-mounting) or before
# formatting one (to avoid destroying a live filesystem).
#
# Usage: device::is_mounted path
#   if device::is_mounted "/dev/sda1"; then echo "already mounted"; fi
#
# Returns: 0 if the device appears in /proc/mounts, 1 otherwise
#
# Note: Linux-only — reads /proc/mounts directly. Does not work on macOS.
device::is_mounted() {
    grep -q "^$1 " /proc/mounts 2>/dev/null \
        || grep -q " $1 " /proc/mounts 2>/dev/null
}

# Check if a device is a loop device (e.g. /dev/loop0).
# Loop devices are used to mount disk image files (.iso, .img) as if they
# were physical block devices. Use this to skip loop devices in listings
# or storage calculations.
#
# Usage: device::is_loop path
#   if device::is_loop "/dev/loop0"; then ...
#
# Returns: 0 if the path starts with /dev/loop, 1 otherwise
device::is_loop() {
    [[ "$1" == /dev/loop* ]]
}

# Check if a device is a RAM disk (/dev/ram*) or compressed RAM block device (/dev/zram*).
# Use this to identify in-memory block devices when enumerating storage or
# filtering out non-persistent devices from disk operations.
#
# Usage: device::is_ram path
#   if device::is_ram "/dev/zram0"; then ...
#
# Returns: 0 if the path is a RAM or zram device, 1 otherwise
device::is_ram() {
    [[ "$1" == /dev/ram* || "$1" == /dev/zram* ]]
}

# Check if a device is a virtual or pseudo device with no physical backing.
# Use this to filter out kernel-provided devices like /dev/null, /dev/zero,
# /dev/random, and /dev/tty* from operations meant only for real hardware.
#
# Usage: device::is_virtual path
#   if device::is_virtual "/dev/null"; then ...
#
# Returns: 0 if the path is a known virtual device, 1 otherwise
#
# Note: Matches against a fixed list of well-known virtual paths including
# /dev/null, /dev/zero, /dev/full, /dev/random, /dev/urandom, the standard
# stdio devices, /dev/fd/*, /dev/ptmx, and /dev/tty*.
device::is_virtual() {
    case "$1" in
        /dev/null | /dev/zero | /dev/full | /dev/random | \
        /dev/urandom | /dev/stdin | /dev/stdout | /dev/stderr | \
        /dev/fd/* | /dev/ptmx | /dev/tty*)
            return 0 ;;
        *)
            return 1 ;;
    esac
}

# ==============================================================================
# CLASSIFICATION
# ==============================================================================

# Identify the type of a device and return it as a plain string.
# Use this to make branching decisions about how to handle a device path
# without having to call multiple is_* functions yourself.
#
# Usage: device::type path
#   type=$(device::type "/dev/sda1")
#
# Returns: echoes one of: virtual, loop, ram, tty, pty, partition, nvme,
# disk, optical, usb, block, char, or unknown
device::type() {
    local dev="$1"
    local base="${dev##*/}"

    # Virtual/pseudo devices first
    device::is_virtual "$dev" && echo "virtual"   && return
    device::is_loop "$dev"    && echo "loop"      && return
    device::is_ram "$dev"     && echo "ram"       && return

    # TTY / PTY
    [[ "$dev" == /dev/tty*  ]] && echo "tty" && return
    [[ "$dev" == /dev/pts/* ]] && echo "pty" && return

    # NVMe
    [[ "$base" =~ ^nvme[0-9]+n[0-9]+p[0-9]+$ ]] && echo "partition" && return
    [[ "$base" =~ ^nvme[0-9]+n[0-9]+$        ]] && echo "nvme"      && return

    # SD/SAS/SATA partitions vs disks
    [[ "$base" =~ ^sd[a-z]+[0-9]+$  ]] && echo "partition" && return
    [[ "$base" =~ ^sd[a-z]+$        ]] && echo "disk"      && return

    # MMC / eMMC
    [[ "$base" =~ ^mmcblk[0-9]+p[0-9]+$ ]] && echo "partition" && return
    [[ "$base" =~ ^mmcblk[0-9]+$        ]] && echo "disk"      && return

    # IDE (legacy)
    [[ "$base" =~ ^hd[a-z]+[0-9]+$ ]] && echo "partition" && return
    [[ "$base" =~ ^hd[a-z]+$       ]] && echo "disk"      && return

    # Optical
    [[ "$base" =~ ^sr[0-9]+$  ]] && echo "optical" && return
    [[ "$base" =~ ^cd[a-z]+$  ]] && echo "optical" && return

    # USB block devices (often shows as sdX — covered above, but flag specific paths)
    [[ "$dev" == /dev/bus/usb/* ]] && echo "usb" && return

    # Generic character vs block fallback
    device::is_block "$dev"  && echo "block" && return
    device::is_device "$dev" && echo "char"  && return

    echo "unknown"
}

# Return the major:minor device number for a device path.
# Major and minor numbers identify the driver and specific instance of a device
# in the kernel. Use this for low-level diagnostics or when interfacing with
# tools that require device numbers rather than paths.
#
# Usage: device::number path
#   device::number "/dev/sda"   # → e.g. "8:0"
#
# Returns: echoes "major:minor" as decimal integers; echoes "unknown" if stat
# is unavailable or the OS is not supported
device::number() {
    local dev="$1"
    if runtime::has_command stat; then
        case "$(runtime::os)" in
        linux|wsl|cygwin|mingw)
            stat -c '%t:%T' "$dev" 2>/dev/null | \
                awk -F: '{ printf "%d:%d\n", strtonum("0x"$1), strtonum("0x"$2) }'
            ;;
        darwin)
            stat -f '%Hr:%Lr' "$dev" 2>/dev/null
            ;;
        *)
            echo "unknown"
            ;;
        esac
    else
        echo "unknown"
    fi
}

# Return the filesystem type on a block device (e.g. ext4, xfs, vfat).
# Use this to check compatibility before mounting, or to decide which
# tools to invoke for repair or inspection.
#
# Usage: device::filesystem path
#   fs=$(device::filesystem "/dev/sda1")   # → e.g. "ext4"
#
# Returns: echoes the filesystem type string; echoes "unknown" if it cannot
# be determined or the required tool is unavailable
#
# Note: Requires blkid on Linux/WSL or diskutil on macOS.
device::filesystem() {
    local dev="$1"
    case "$(runtime::os)" in
    linux|wsl)
        if runtime::has_command blkid; then
            blkid -o value -s TYPE "$dev" 2>/dev/null || echo "unknown"
        else
            echo "unknown"
        fi
        ;;
    darwin)
        diskutil info "$dev" 2>/dev/null \
            | awk -F': +' '/Type \(Bundle\)/ { print $2 }' || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# Return the total size of a block device in bytes.
# Use this when you need an exact byte count for calculations, validation,
# or before writing an image to ensure it fits on the target device.
#
# Usage: device::size_bytes path
#   bytes=$(device::size_bytes "/dev/sda")
#
# Returns: echoes the size in bytes as an integer; echoes "unknown" if the
# size cannot be determined
#
# Note: On Linux, prefers /sys/block (no root needed) then falls back to
# blockdev (may require root). On macOS uses diskutil.
device::size_bytes() {
    local dev="$1"
    case "$(runtime::os)" in
    linux|wsl)
        if [[ -r "/sys/block/${dev##*/}/size" ]]; then
            # /sys/block reports 512-byte sectors
            echo $(( $(cat "/sys/block/${dev##*/}/size") * 512 ))
        elif runtime::has_command blockdev; then
            blockdev --getsize64 "$dev" 2>/dev/null || echo "unknown"
        else
            echo "unknown"
        fi
        ;;
    darwin)
        diskutil info "$dev" 2>/dev/null \
            | awk -F': +' '/Disk Size/ { match($2, /[0-9]+/, a); print a[0] }' \
            || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# Return the total size of a block device in megabytes (integer).
# Use this for human-readable size checks or when you need MB rather than
# raw bytes for comparison or display.
#
# Usage: device::size_mb path
#   device::size_mb "/dev/sda"   # → e.g. "61440"
#
# Returns: echoes the size in whole MB; echoes "unknown" if the size cannot
# be determined
device::size_mb() {
    local bytes
    bytes=$(device::size_bytes "$1")
    [[ "$bytes" == "unknown" ]] && echo "unknown" && return
    echo $(( bytes / 1024 / 1024 ))
}

# Return the mount point of a block device, or an empty string if not mounted.
# Use this to find where a device is accessible in the filesystem, for example
# to construct paths to files on a mounted drive.
#
# Usage: device::mount_point path
#   mp=$(device::mount_point "/dev/sda1")   # → e.g. "/mnt/data"
#
# Returns: echoes the mount point path; echoes nothing if the device is not mounted
device::mount_point() {
    local dev="$1"
    case "$(runtime::os)" in
    linux|wsl)
        grep "^$dev " /proc/mounts 2>/dev/null | awk '{print $2}' | head -1
        ;;
    darwin)
        diskutil info "$dev" 2>/dev/null \
            | awk -F': +' '/Mount Point/ { print $2 }'
        ;;
    *)
        echo ""
        ;;
    esac
}

# ==============================================================================
# LISTING
# ==============================================================================

# List all physical block devices on the system (excluding loop devices).
# Use this to enumerate real storage devices for inspection, selection, or
# scripted disk operations.
#
# Usage: device::list::block
#   for dev in $(device::list::block); do ...
#
# Returns: echoes one device path per line (e.g. /dev/sda); echoes "unknown"
# on unsupported platforms
device::list::block() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME 2>/dev/null | sed 's/^/\/dev\//' | grep -v loop
        ;;
    darwin)
        diskutil list 2>/dev/null | awk '/^\/dev\// { print $1 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# List all character devices in /dev (sorted).
# Use this to enumerate devices like terminals, serial ports, and pseudo-devices
# when you need to inspect or iterate over available character device nodes.
#
# Usage: device::list::char
#   device::list::char | grep tty
#
# Returns: echoes one device path per line, sorted alphabetically
device::list::char() {
    find /dev -maxdepth 1 -type c 2>/dev/null | sort
}

# List all TTY character devices in /dev (sorted).
# Use this to find available terminal devices, for example when scripting
# serial communication or enumerating console ports.
#
# Usage: device::list::tty
#   device::list::tty
#
# Returns: echoes one TTY device path per line, sorted alphabetically
device::list::tty() {
    find /dev -maxdepth 1 -name 'tty*' -type c 2>/dev/null | sort
}

# List all loop block devices in /dev (sorted).
# Use this to see which loop devices exist, for example to find one that is
# free before mounting a disk image, or to audit active loop device usage.
#
# Usage: device::list::loop
#   device::list::loop
#
# Returns: echoes one loop device path per line, sorted alphabetically
device::list::loop() {
    find /dev -maxdepth 1 -name 'loop*' -type b 2>/dev/null | sort
}

# List all currently mounted block devices alongside their mount points.
# Use this to get a quick overview of what storage is in use and where it is
# accessible in the filesystem.
#
# Usage: device::list::mounted
#   device::list::mounted
#
# Returns: echoes "device mountpoint" pairs, one per line; echoes "unknown"
# on unsupported platforms
device::list::mounted() {
    case "$(runtime::os)" in
    linux|wsl)
        grep '^/dev/' /proc/mounts 2>/dev/null | awk '{print $1, $2}'
        ;;
    darwin)
        mount 2>/dev/null | awk '/^\/dev\// { print $1, $3 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# ==============================================================================
# SPECIAL DEVICES
# ==============================================================================

# Write zero bytes to a device or file from /dev/zero.
# Use this to wipe the start of a disk before partitioning, zero-fill a file,
# or clear a device's header to make it unrecognisable to filesystem tools.
#
# Usage: device::zero target [bytes]
#   device::zero "/dev/sdb" 512    # wipe first 512 bytes (MBR)
#   device::zero "scratch.img" 1024
#
# Returns: 0 on success, 1 on failure
#
# Warning: Destructive and irreversible. Always double-check the target path
# before running — there is no confirmation prompt.
device::zero() {
    local target="$1" bytes="${2:-16}"
    if [[ -n "$bytes" ]]; then
        dd if=/dev/zero of="$target" bs=1 count="$bytes" 2>/dev/null
    else
        dd if=/dev/zero of="$target" 2>/dev/null
    fi
}

# Read random bytes from /dev/urandom and print them as a hex string.
# Use this to generate random tokens, nonces, or test data without pulling
# in external tools like openssl or python.
#
# Usage: device::random [bytes]
#   device::random 16    # → e.g. "a3f1c8204e6b91d057..."
#   token=$(device::random 32)
#
# Returns: echoes a lowercase hex string of the requested length; defaults to
# 16 bytes (32 hex characters) if no argument is given
device::random() {
    local bytes="${1:-16}"
    dd if=/dev/urandom bs=1 count="$bytes" 2>/dev/null | od -An -tx1 | tr -d ' \n'
    echo
}

# Verify that /dev/null is functional by writing to it.
# Use this as a sanity check in scripts that depend on /dev/null for silencing
# output — in broken or containerised environments it can sometimes be missing
# or misconfigured.
#
# Usage: device::null_ok
#   if ! device::null_ok; then echo "/dev/null is broken"; fi
#
# Returns: 0 if writing to /dev/null succeeds, 1 otherwise
device::null_ok() {
    echo "" > /dev/null 2>&1
}

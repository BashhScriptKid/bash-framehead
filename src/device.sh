#!/usr/bin/env bash
# device.sh — bash-frameheader device lib
# Requires: runtime.sh (runtime::os, runtime::has_command)

# ==============================================================================
# INSPECTION
# ==============================================================================

# Check if path is a character device
device::is_device() {
    [[ -c "$1" ]]
}

# Check if path is a block device
device::is_block() {
    [[ -b "$1" ]]
}

# Check if device is writable
device::is_writeable() {
    [[ -w "$1" ]]
}

# Check if device is readable
device::is_readable() {
    [[ -r "$1" ]]
}

# Check if device exists (block or character)
device::exists() {
    [[ -b "$1" || -c "$1" ]]
}

# Check if device has open file handles via lsof
device::has_processes() {
    runtime::has_command lsof || return 1
    lsof -t "$1" >/dev/null 2>&1
}

# Check if device is occupied via /proc (no lsof needed)
device::is_occupied() {
    find /proc/[0-9]*/fd -lname "*${1#/dev/}" 2>/dev/null | head -1 | grep -q .
}

# Check if a block device is mounted
device::is_mounted() {
    grep -q "^$1 " /proc/mounts 2>/dev/null \
        || grep -q " $1 " /proc/mounts 2>/dev/null
}

# Check if device is a loop device
device::is_loop() {
    [[ "$1" == /dev/loop* ]]
}

# Check if device is a RAM disk
device::is_ram() {
    [[ "$1" == /dev/ram* || "$1" == /dev/zram* ]]
}

# Check if device is a virtual/pseudo device
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

# Returns the type of a device as a string
# Possible returns: block, char, loop, ram, disk, partition, nvme,
#                   virtual, tty, pty, usb, optical, unknown
device::type() {
    local base="${1##*/}"

    # Virtual/pseudo devices first
    device::is_virtual "$1" && echo "virtual"   && return
    device::is_loop "$1"    && echo "loop"      && return
    device::is_ram "$1"     && echo "ram"       && return

    # TTY / PTY
    [[ "$1" == /dev/tty*  ]] && echo "tty" && return
    [[ "$1" == /dev/pts/* ]] && echo "pty" && return

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

# Returns the major:minor device number
device::number() {
    if runtime::has_command stat; then
        case "$(runtime::os)" in
        linux|wsl|cygwin|mingw)
            stat -c '%t:%T' "$1" 2>/dev/null | \
                awk -F: '{ printf "%d:%d\n", strtonum("0x"$1), strtonum("0x"$2) }'
            ;;
        darwin)
            stat -f '%Hr:%Lr' "$1" 2>/dev/null
            ;;
        *)
            echo "unknown"
            ;;
        esac
    else
        echo "unknown"
    fi
}

# Returns the filesystem on a block device (if mounted or detectable)
# Requires: blkid (Linux) or diskutil (macOS)
device::filesystem() {
    case "$(runtime::os)" in
    linux|wsl)
        if runtime::has_command blkid; then
            blkid -o value -s TYPE "$1" 2>/dev/null || echo "unknown"
        else
            echo "unknown"
        fi
        ;;
    darwin)
        diskutil info "$1" 2>/dev/null \
            | awk -F': +' '/Type \(Bundle\)/ { print $2 }' || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# Returns the size of a block device in bytes
device::size_bytes() {
    case "$(runtime::os)" in
    linux|wsl)
        if [[ -r "/sys/block/${1##*/}/size" ]]; then
            # /sys/block reports 512-byte sectors
            echo $(( $(cat "/sys/block/${1##*/}/size") * 512 ))
        elif runtime::has_command blockdev; then
            blockdev --getsize64 "$1" 2>/dev/null || echo "unknown"
        else
            echo "unknown"
        fi
        ;;
    darwin)
        diskutil info "$1" 2>/dev/null \
            | awk -F': +' '/Disk Size/ { match($2, /[0-9]+/, a); print a[0] }' \
            || echo "unknown"
        ;;
    *)
        echo "unknown"
        ;;
    esac
}

# Returns the size of a block device in MB
device::size_mb() {
    local bytes
    bytes=$(device::size_bytes "$1")
    [[ "$bytes" == "unknown" ]] && echo "unknown" && return
    echo $(( bytes / 1024 / 1024 ))
}

# Returns the mount point of a block device (empty if not mounted)
device::mount_point() {
    case "$(runtime::os)" in
    linux|wsl)
        grep "^$1 " /proc/mounts 2>/dev/null | awk '{print $2}' | head -1
        ;;
    darwin)
        diskutil info "$1" 2>/dev/null \
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

# List all block devices
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

# List all character devices
device::list::char() {
    find /dev -maxdepth 1 -type c 2>/dev/null | sort
}

# List all TTY devices
device::list::tty() {
    find /dev -maxdepth 1 -name 'tty*' -type c 2>/dev/null | sort
}

# List all loop devices
device::list::loop() {
    find /dev -maxdepth 1 -name 'loop*' -type b 2>/dev/null | sort
}

# List mounted devices with their mount points
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

# Write n bytes of zeros to a device or file (wraps /dev/zero)
# Usage: device::zero target [bytes]
# WARNING: Destructive — use with care
device::zero() {
    local target="$1" bytes="${2:-16}"
    if [[ -n "$bytes" ]]; then
        dd if=/dev/zero of="$target" bs=1 count="$bytes" 2>/dev/null
    else
        dd if=/dev/zero of="$target" 2>/dev/null
    fi
}

# Read n random bytes from /dev/urandom
# Usage: device::random [bytes]
device::random() {
    dd if=/dev/urandom bs=1 count="${1:-16}" 2>/dev/null | od -An -tx1 | tr -d ' \n'
    echo
}

# Check if /dev/null is functional (sanity check)
device::null_ok() {
    echo "" > /dev/null 2>&1
}

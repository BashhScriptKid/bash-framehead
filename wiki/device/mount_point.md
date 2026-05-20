# `device::mount_point`

Returns the mount point of a block device (empty if not mounted)

## Source

```bash
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
```

## Module

[`device`](../device.md)

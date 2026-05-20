# `device::filesystem`

Returns the filesystem on a block device (if mounted or detectable)

**Requires:** blkid (Linux) or diskutil (macOS)

## Source

```bash
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
```

## Module

[`device`](../device.md)

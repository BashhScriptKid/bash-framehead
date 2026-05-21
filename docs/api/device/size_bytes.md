# `device::size_bytes`

**Signature:** `device::size_bytes(arg1, arg2)`

**Module:** [`device`](../device.md) — [Guide](../guide/index.md)

**Return:** stdout — prints result

## Description

Returns the size of a block device in bytes

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg1` | string | Yes | |
| `arg2` | string | Yes | |

## Source

```bash
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
```


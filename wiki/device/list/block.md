# `device::list::block`

List all block devices

## Source

```bash
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
```

## Module

[`device`](../device.md)

# `hardware::disk::count::virtual`

_No description available._

## Source

```bash
hardware::disk::count::virtual() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME,TYPE 2>/dev/null | grep -c 'loop\|ram'
        ;;
    darwin)
        diskutil list 2>/dev/null | grep -c 'virtual'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)

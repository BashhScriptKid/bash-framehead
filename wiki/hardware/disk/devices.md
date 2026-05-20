# `hardware::disk::devices`

_No description available._

## Source

```bash
hardware::disk::devices() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME 2>/dev/null | grep -v '^loop' | tr '\n' ' ' | xargs
        ;;
    darwin)
        diskutil list 2>/dev/null | awk '/^\/dev\/disk/ { print $1 }' | tr '\n' ' ' | xargs
        ;;
    freebsd|dragonfly|openbsd|netbsd)
        sysctl -n kern.disks 2>/dev/null | tr ' ' '\n' | grep -v '^$' | tr '\n' ' ' | xargs
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)

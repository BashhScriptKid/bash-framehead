# `hardware::ram::totalSpaceMB`

_No description available._

## Source

```bash
hardware::ram::totalSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/MemTotal/ { printf "%d\n", $2/1024 }' /proc/meminfo
        ;;
    darwin)
        sysctl -n hw.memsize | awk '{ printf "%d\n", $1/1024/1024 }'
        ;;
    freebsd|dragonfly)
        sysctl -n hw.physmem 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
        ;;
    netbsd)
        sysctl -n hw.physmem64 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
        ;;
    openbsd)
        sysctl -n hw.physmem 2>/dev/null | awk '{ printf "%d\n", $1/1024/1024 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)

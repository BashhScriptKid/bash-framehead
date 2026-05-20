# `hardware::swap::freeSpaceMB`

_No description available._

## Source

```bash
hardware::swap::freeSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/SwapFree/ { printf "%d\n", $2/1024 }' /proc/meminfo
        ;;
    darwin)
        sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$9); print $9 }'
        ;;
    freebsd|dragonfly)
        local total used
        total=$(hardware::swap::totalSpaceMB)
        used=$(hardware::swap::usedSpaceMB)
        echo $(( total - used ))
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)

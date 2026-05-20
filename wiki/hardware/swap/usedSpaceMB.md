# `hardware::swap::usedSpaceMB`

_No description available._

## Source

```bash
hardware::swap::usedSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/SwapTotal/ { total=$2 } /SwapFree/ { free=$2 }
             END { printf "%d\n", (total-free)/1024 }' /proc/meminfo
        ;;
    darwin)
        sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$6); print $6 }'
        ;;
    freebsd|dragonfly)
        swapinfo -k 2>/dev/null | awk 'NR>1 { used+=$3 } END { printf "%d\n", used/1024 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)

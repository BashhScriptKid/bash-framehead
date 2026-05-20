# `hardware::swap::totalSpaceMB`

_No description available._

## Source

```bash
hardware::swap::totalSpaceMB() {
    case "$(runtime::os)" in
    linux|wsl|cygwin|mingw)
        awk '/SwapTotal/ { printf "%d\n", $2/1024 }' /proc/meminfo
        ;;
    darwin)
        sysctl -n vm.swapusage 2>/dev/null | awk '{ gsub(/M/,"",$3); print $3 }'
        ;;
    freebsd|dragonfly)
        swapinfo -k 2>/dev/null | awk 'NR>1 { total+=$2 } END { printf "%d\n", total/1024 }'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

## Module

[`hardware`](../hardware.md)

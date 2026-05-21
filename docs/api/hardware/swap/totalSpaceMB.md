# `hardware::swap::totalSpaceMB`

**Signature:** `hardware::swap::totalSpaceMB(arg2, arg3)`

**Module:** [`hardware`](../../hardware.md) — [Guide](../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._

## Parameters

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `arg2` | string | Yes | |
| `arg3` | string | Yes | |

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


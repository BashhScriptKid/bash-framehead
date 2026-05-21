# `hardware::disk::count::physical`

**Signature:** `hardware::disk::count::physical()`

**Module:** [`hardware`](../../../hardware.md) — [Guide](../../../guide/index.md)

**Return:** stdout — prints result

## Description

_No description available._


## Source

```bash
hardware::disk::count::physical() {
    case "$(runtime::os)" in
    linux|wsl)
        lsblk -dno NAME,TYPE 2>/dev/null | awk '/disk/ && !/loop/' | wc -l | xargs
        ;;
    darwin)
        diskutil list physical 2>/dev/null | grep -c '^/dev/disk'
        ;;
    *)
        echo "unknown"
        ;;
    esac
}
```

